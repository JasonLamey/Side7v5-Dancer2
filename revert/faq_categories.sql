-- Revert side7v5:faq_categories from mysql

BEGIN;

DROP TABLE faq_categories;

COMMIT;
