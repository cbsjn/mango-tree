class SyncingError < ApplicationRecord
	SYNC_CUSTOMER_TO_QBO = 'Sync Customer To QBO'
	SYNC_SALES_RECEIPT_TO_QBO = 'Sync SalesReceipt To QBO'
	SYNC_INVOICE_TO_QBO = 'Sync Invoice To QBO'
	SYNC_PAYMENT_TO_QBO = 'Sync Payment To QBO'
	SYNC_TOKENS_FROM_QBO = 'Sync Tokens From QBO'
end
