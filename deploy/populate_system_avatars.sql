-- Deploy side7v5:populate_system_avatars to mysql
-- requires: system_avatars
-- requires: appuser

BEGIN;

INSERT INTO `system_avatars` VALUES (1,'american_gothic.jpg','American Gothic','2014-10-03 00:00:00','2014-10-03 00:00:00'),(2,'art_gallery.gif','Art Gallery','2014-10-03 00:00:00','2014-10-03 00:00:00'),(3,'big_red_eyes.gif','Big Red Eyes','2014-10-03 00:00:00','2014-10-03 00:00:00'),(4,'cat_fan.gif','Cat Fan','2014-10-03 00:00:00','2014-10-03 00:00:00'),(5,'cat_is_bored.gif','Cat Is Bored','2014-10-03 00:00:00','2014-10-03 00:00:00'),(6,'cat_piano.gif','Cat Piano','2014-10-03 00:00:00','2014-10-03 00:00:00'),(7,'cosmic_christ_alex_grey.jpg','Cosmic Christ by Alex Grey','2014-10-03 00:00:00','2014-10-03 00:00:00'),(8,'excalibur.jpg','Excalibur','2014-10-03 00:00:00','2014-10-03 00:00:00'),(9,'find_pieces.jpg','Find Pieces','2014-10-03 00:00:00','2014-10-03 00:00:00'),(10,'funny_penguin.gif','Funny Penguin','2014-10-03 00:00:00','2014-10-03 00:00:00'),(11,'girl_b_n_w_art.jpg','Girl Black &amp; White Art','2014-10-03 00:00:00','2014-10-03 00:00:00'),(12,'girl_gas_mask.jpg','Girl Gas Mask','2014-10-03 00:00:00','2014-10-03 00:00:00'),(13,'mona_lisa.jpg','Mona Lisa by Leonardo DaVinci','2014-10-03 00:00:00','2014-10-03 00:00:00'),(14,'nature_art.gif','Nature Art','2014-10-03 00:00:00','2014-10-03 00:00:00'),(15,'pastels.gif','Pastels','2014-10-03 00:00:00','2014-10-03 00:00:00'),(16,'some_different_world.jpg','Some Different World','2014-10-03 00:00:00','2014-10-03 00:00:00'),(17,'thea.jpg','Thea','2014-10-03 00:00:00','2014-10-03 00:00:00'),(18,'typing_cat.gif','Typing Cat','2014-10-03 00:00:00','2014-10-03 00:00:00');

COMMIT;
