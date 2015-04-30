@GeoNet/db/Basic_Data_Creation.sql
INSERT INTO users SELECT users_seq.NEXTVAL, 'Helvey', 'Eric', 'L', 'eric.l.helvey@mail.sprint.com', 'EricHelvey' FROM DUAL;
INSERT INTO user_group_user_map VALUES (1, 1);
INSERT INTO user_group_user_map VALUES (2, 1);
INSERT INTO user_group_user_map VALUES (3, 1);
INSERT INTO user_group_user_map VALUES (4, 1);
INSERT INTO user_group_user_map VALUES (5, 1);


