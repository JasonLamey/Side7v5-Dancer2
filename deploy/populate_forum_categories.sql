-- Deploy side7v5:populate_forum_categories to mysql
-- requires: appuser
-- requires: forum_categories

BEGIN;

INSERT INTO `forum_categories`
VALUES
(4,'Site Feedback',10,'Any','Any'),
(5,'Art',40,'Any','Any'),
(6,'Contests and Challenges',30,'Any','Any'),
(7,'Side 7 Radio',20,'Any','Any'),
(8,'Community',50,'Any','Any'),
(9,'Administrative Forums',998,'Registered','Registered'),
(1,'Deleted Items',999,'Admin','Admin');

COMMIT;
