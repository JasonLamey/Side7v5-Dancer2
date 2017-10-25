-- Revert side7v5:faq_entries from mysql

BEGIN;

DROP TABLE faq_entries;

COMMIT;
