namespace :sync_to_qbo  do
  desc "Sync Customers To QBO"
  task :sync_customers => :environment do
    User.all.each do |u|
    	begin
    		customers = Customer.not_synced(u)
    		customers.each do |customer|
    			begin
    				result = Customer.sync_customers_to_qbo(u, customer)
    				if result
	    				puts "Customer Synced to QBO : #{customer.email}"
	    			else
	    				puts "Error Occurred while saving customer #{customer.email}"
	    			end
    			rescue Exception => ex
			    	puts "Inner Loop Exception : #{ex.inspect}"
			    	SyncingError.create(user_id: u.id, error_type: SyncingError::SYNC_CUSTOMER_TO_QBO, description: ex.message)
			    end
    		end
	    rescue Exception => ex
	    	puts "Outer Loop Exception : #{ex.inspect}"
        SyncingError.create(user_id: u.id, error_type: SyncingError::SYNC_CUSTOMER_TO_QBO, description: ex.inspect)
	    end
    end
  end

  desc "Sync SalesReceipts To QBO"
  task :sync_sales_receipts => :environment do
    User.all.each do |u|
      begin
        sales_receipts = SalesReceipt.not_synced(u)
        sales_receipts.each do |sales_receipt|
          begin
            result = SalesReceipt.sync_receipt_to_qbo(u, sales_receipt)
            if result
              puts "SalesReceipt Synced to QBO : #{sales_receipt.id}"
            else
              puts "Error Occurred while saving SalesReceipt #{sales_receipt.id}"
            end
          rescue Exception => ex
            puts "Inner Loop Exception : #{ex.inspect}"
            SyncingError.create(user_id: u.id, error_type: SyncingError::SYNC_SALES_RECEIPT_TO_QBO, description: ex.message)
          end
        end
      rescue Exception => ex
        puts "Outer Loop Exception : #{ex.inspect}"
        SyncingError.create(user_id: u.id, error_type: SyncingError::SYNC_SALES_RECEIPT_TO_QBO, description: ex.inspect)
      end
    end
  end

  desc "Sync Invoices To QBO"
  task :sync_invoices => :environment do
    User.all.each do |u|
      begin
        reservations = Reservation.not_synced(u)
        reservations.each do |reservation|
          if reservation.customer&.qbo_id.present?
            invoices = Transaction.invoices(u, reservation.id)
            unless invoices.count.zero?
              begin
                Reservation.sync_invoice_to_qbo(u, invoices, reservation)
                puts "Synced Reservation #{reservation.id} Succesfully to QBO"
              rescue Exception => ex
                puts "Inner Loop Exception for Reservation : #{reservation.id} => Message #{ex.inspect}"
                SyncingError.create(user_id: u.id, error_type: SyncingError::SYNC_INVOICE_TO_QBO, description: ex.message)
              end 
            end
          else
            SyncingError.create(user_id: u.id, error_type: SyncingError::SYNC_INVOICE_TO_QBO, description: "Please Sync Customer #{reservation.customer.email} to QBO before syncing Invoices.")
          end
        end
      rescue Exception => ex
        puts "Outer Loop Exception : #{ex.inspect}"
        SyncingError.create(user_id: u.id, error_type: SyncingError::SYNC_INVOICE_TO_QBO, description: ex.inspect)
      end
    end
  end

  desc "Sync Payments To QBO"
  task :sync_payments => :environment do
    User.all.each do |u|
      begin
        payments = Transaction.payments(u)
        payments.each do |transaction|
          reservation = transaction.reservation
          if reservation.qbo_invoice_id.present?
            synced_invoices = Transaction.synced_invoices(u, reservation.id)
            qbo_payment_method_id = PaymentMethod.get_qbo_mapped_payment_method(u.id, transaction.category)
            if qbo_payment_method_id.present?
              begin
                Transaction.sync_payment_to_qbo(u, reservation, transaction, synced_invoices, qbo_payment_method_id)
                puts "Synced payment #{transaction.id} successfully to QBO"
              rescue Exception => ex
                puts "Inner Loop Exception for Payment : #{transaction.id} => Message #{ex.inspect}"
                SyncingError.create(user_id: u.id, error_type: SyncingError::SYNC_PAYMENT_TO_QBO, description: ex.message)
              end 
            else
              puts "Please Create Mapping of PaymentMethod before syncing for transaction #{transaction.id}"
            end
          else
            SyncingError.create(user_id: u.id, error_type: SyncingError::SYNC_PAYMENT_TO_QBO, description: "Please Sync Invoice for reservation : #{reservation.id} to QBO before syncing Payments.")
            puts "Please create invoice before syncing payment for reservation : #{reservation.id}"
          end
        end
      rescue Exception => ex
        puts "Outer Loop Exception : #{ex.inspect}"
        SyncingError.create(user_id: u.id, error_type: SyncingError::SYNC_PAYMENT_TO_QBO, description: ex.inspect)
      end
    end
  end
end