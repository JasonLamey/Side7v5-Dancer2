-- Verify side7v5:faq_categories on mysql

BEGIN;

SELECT category
  FROM faq_categories
 WHERE 0;

ROLLBACK;
