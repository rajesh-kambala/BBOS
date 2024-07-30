
SET NOCOUNT ON

DECLARE @ForCommit bit
-- SET this variable to 1 to commit changes

SET @ForCommit = 1;

if (@ForCommit = 0) begin
	PRINT '*************************************************************'
	PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
	PRINT '*************************************************************'
	PRINT ''
end

DECLARE @Start DateTime
SET @Start = GETDATE()
PRINT 'Execution Start: ' + CONVERT(VARCHAR(20), @Start, 100) + ' on server ' + @@SERVERNAME
PRINT ''

BEGIN TRANSACTION
BEGIN TRY


--DECLARE @Start datetime = GETDATE()

DECLARE @MyTable table (
	ndx int identity(1,1) primary key,
	CompanyID int,
	AttentionLine varchar(200),
	PersonID int,
	Associate1 varchar(10),
	Associate2 varchar(10),
	Associate3 varchar(10),
	FieldRep varchar(10))

--  ="INSERT INTO @MyTable VALUES (" & A2 & ", '" & C2 & "', " & D2 & ",  '" & E2 & "', '" & F2 & "', '" & G2 & "', '" & H2 & "');"


INSERT INTO @MyTable VALUES (287422, 'David Esquivel', 45302,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (149982, 'Mark Williams', 24926,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (169698, 'Andrew Martin', 15695,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (119928, 'Joe Douglas', 23399,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (170541, 'Elliott Klahr', 17416,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (210364, 'Mike Eastman', 94787,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (149785, 'Andrew Gurda', 19278,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (103951, 'Nick Pacia', 27517,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (120506, 'Marshall Kipp & Tammy Watson', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (160288, 'Judy Wolfe', 40343,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (170926, 'Irma Villarreal & Armando Flores', 0,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (289411, 'Pat Compres', 49587,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (158193, 'Michael Sullivan', 2260,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (191938, 'Alfredo Rodriguez', 82040,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (256009, 'Marcus Shalaby', 157591,  'TAJ', 'MDE', '', '');
INSERT INTO @MyTable VALUES (211629, 'Delia Shirley', 218621,  'TAJ', 'ZMC', '', '');
INSERT INTO @MyTable VALUES (139562, 'Michael McCoy', 71087,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (281967, 'Guillermo (Alex) Alejandro Morachis Patino', 122544,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (335477, 'Alex Rosen', 231302,  'DCN', '', '', '');
INSERT INTO @MyTable VALUES (329898, 'Mike Snow', 220320,  'CDT', 'MDE', '', '');
INSERT INTO @MyTable VALUES (165875, 'Justin Van Loben Sels', 56981,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (181065, 'Rene Romero', 83482,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (209890, 'Luis Hermosillo', 115889,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (233387, 'Whit Grebitus', 128790,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (125044, 'John King', 12681,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (104524, 'Jeffrey Abrash', 22497,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (209447, 'Alejandro Canelos', 92391,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (269689, 'Roberto Franzone & George Agorastos', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (211354, 'Rita Arling', 96135,  'TAJ', 'ZMC', 'MDE', '');
INSERT INTO @MyTable VALUES (329870, 'Geoff Berwick', 163718,  'TAJ', '', '', '');
INSERT INTO @MyTable VALUES (168165, 'Jamy Rosenstein', 62670,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (172604, 'Brian Gibson', 231379,  'TBP', '', '', '');
INSERT INTO @MyTable VALUES (170464, 'Mauro Moreno', 20351,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (106159, 'Danny Arnold & Chad Szutz', 0,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (157008, 'Jody Carkner', 61912,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (168111, 'Avi Nir', 56761,  'TBP', 'BMZ', '', 'CAS');
INSERT INTO @MyTable VALUES (106499, 'Steven (Steve) L. Catalani', 23735,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (249209, 'Tony Cimorelli', 177131,  'TAJ', 'MDE', '', '');
INSERT INTO @MyTable VALUES (123034, 'Jeremy Lane', 53312,  'DCN', '', '', 'TWH');
INSERT INTO @MyTable VALUES (292625, 'Mark O''Sullivan', 156400,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (259761, 'Justin Bedwell', 52474,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (233525, 'Barry Schneider', 96784,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (141688, 'Aquiles (Jaime) J. Garza', 37918,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (260702, 'Andrew Ruggiero', 34102,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (104793, 'Nate Stone & Kyle Stone', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (105716, 'Howard P. Hallam', 18967,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (111898, 'Ben Litowich', 8075,  'TBP', 'BMZ', '', 'CAS');
INSERT INTO @MyTable VALUES (171994, 'Andy Kahu', 36111,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (207113, 'Michael Orsini', 23098,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (104641, 'Mariana Celaya', 19524,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (158406, 'Jesus Lopez Jr', 19544,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (261138, 'Lourdes Camacho', 94896,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (171605, 'Roger Riehm', 50205,  'TBP', '', '', '');
INSERT INTO @MyTable VALUES (211404, 'Gordon Bird', 115308,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (155967, 'Angus Alvarez & Kara Garcia', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (106833, 'Tony Garcia', 19615,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (120996, 'Lindsay Ehlis, Darrin Carpenter, & Denny Annen', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (233405, 'Karen Nakatsuru', 118218,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (337059, 'Heidi Nielsen', 234132,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (161417, 'Randy Dietrich', 44774,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (121206, 'Martin S. Erenwert', 31405,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (109306, 'Terry Newlon', 26335,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (187846, 'Mark Prenger', 153616,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (233477, 'Ed List', 96688,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (147309, 'Ramon Murillo Jr', 19654,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (210484, 'Claudio Madid', 14912,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (207623, 'Paul Smit', 90577,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (153593, 'Megan Silcott', 234133,  'TBP', '', '', 'TWH');
INSERT INTO @MyTable VALUES (268157, 'Garrick Macek', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (113025, 'Sarah Alvernaz', 88779,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (169611, 'T.J. Risco', 142587,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (134144, 'Joe Calixtro', 19659,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (145073, 'Walt Tindell', 9963,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (117489, 'Nick Pitsikoulis', 22873,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (258111, 'Murray Vogt', 116072,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (153602, 'Jane Proctor & Ron Lemaire', 0,  'TBP', 'JBL', 'TWH', 'FMS');
INSERT INTO @MyTable VALUES (105849, 'William (Bill) J. Canino', 31433,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (256895, 'Savita Naidu', 172718,  'TAJ', 'ZMC', '', '');
INSERT INTO @MyTable VALUES (233421, 'Bill Bayne', 96598,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (149375, 'Troy Mesa', 23683,  'TBP', '', '', '');
INSERT INTO @MyTable VALUES (115654, 'Peter Carcione', 1443,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (148979, 'Brenda  Leighton', 2344,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (139574, 'Carlo & Sam Ciaramitaro', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (211672, 'Reg Foot', 112934,  'TAJ', 'MDE', '', '');
INSERT INTO @MyTable VALUES (142759, 'Laura Berryessa', 8351,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (129568, 'Tony (Skip) D. Hudler III', 31444,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (113987, 'Jan Garrett', 69391,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (169939, 'John Della Santina', 93894,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (258937, 'Amara Marshall', 114117,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (291443, 'Barbara Hochman', 141919,  'KAO', 'MDE', '', '');
INSERT INTO @MyTable VALUES (110459, 'Shannon Barthel', 8161,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (211357, 'Richard Allen', 96146,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (303011, 'Jacob Boles', 177450,  'TAJ', '', '', '');
INSERT INTO @MyTable VALUES (116171, 'Sylvie Guinois', 168293,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (100586, 'Drew Schwartzhoff', 124758,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (302259, 'Muhammad Babar Khan', 176494,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (134663, 'Martin Gyuro', 33950,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (105857, 'Owen E. Torres', 31452,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (170403, 'Mac Riggan', 17163,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (151227, 'Jean-Francois Chenail', 22877,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (168125, 'Harriet Mills', 108837,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (113235, 'Jack Choumas Jr.', 31938,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (151376, 'Jeff & Chuck Olsen', 0,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (152079, 'Emerson Nelson', 23863,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (292917, 'Salvador (Chava) Garcia', 157205,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (298918, 'Joaquin Spamer', 40211,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (155976, 'Chris & Chuck Ciruli', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (168337, 'Steve Kocsis', 63057,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (108797, 'Debra Sanford', 8549,  'DCN', '', '', '');
INSERT INTO @MyTable VALUES (113248, 'Mark Morimoto, Tony Moreno, & Victoria Parr', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (170501, 'Paul Coleman', 63102,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (160640, 'Marco (Antonio) Gudino Hernandez', 42928,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (104076, 'John Collotti, Jr.', 18975,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (283429, 'Christian Collier', 80331,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (167297, 'Elvia Menendez', 48722,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (301400, 'Dan Coogan & Kip Martin', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (125423, 'Fred Plotsky', 32404,  'TBP', '', '', 'TWH');
INSERT INTO @MyTable VALUES (152984, 'Mark Pappas', 21478,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (148902, 'Daniel (Danny) F. Coosemans', 954,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (154447, 'Dale Firman', 16134,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (161591, 'Connie Galluci', 16923,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (154404, 'Danny Coosemans & Rebecca Rasmussens', 0,  'JBL', 'CJC', '', 'FMS');
INSERT INTO @MyTable VALUES (115999, 'Guy Milette', 0,  'BMZ', 'TBP', '', 'FMS');
INSERT INTO @MyTable VALUES (163850, 'Atomic Torosian', 9609,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (297018, 'Joe Guyette & Chris Erickson', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (101917, 'Nick Gaglione & Sam Gaglione', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (103870, 'James Hunt, Jr.', 61775,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (196583, 'Samit Thakker', 112741,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (279860, 'Rene Calixtro', 8818,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (279868, 'Dwayne Kepner', 138344,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (211595, 'Roy Falletta', 109802,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (103639, 'Matthew D''Arrigo & Gabriela D''Arrigo', 0,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (111825, 'Kathy Evan', 2895,  'VJB', '', '', 'TWH');
INSERT INTO @MyTable VALUES (116424, 'Doug Grant', 64961,  'TBP', '', '', '');
INSERT INTO @MyTable VALUES (107658, 'Greg Lee', 10908,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (163269, 'Diego Ley Lopez', 43261,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (112306, 'Robert Lucy', 18868,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (270666, 'Rigoberto Avila', 65765,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (329714, 'Paul Grothe', 11216,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (260906, 'Zoraida Cordoba', 150600,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (149794, 'William & Maritza Graney', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (258938, 'Dean Garofano', 107182,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (268158, 'Thanasi Panousopoulos', 65044,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (147056, 'Michael DeLellis', 130786,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (108946, 'Jimmy DeMatteis', 7427,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (288900, 'Bram Hulshoff', 155509,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (101291, 'Tim Wetherbee', 4210,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (190347, 'Jorge Antona', 66877,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (169584, 'Paul J. DiMare', 1189,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (204689, 'Jose Antonio Martinez', 173438,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (188910, 'Dan''l Mackey Almy', 86964,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (254917, 'Beth DeGeorge', 162949,  'TAJ', 'MDE', '', '');
INSERT INTO @MyTable VALUES (113721, 'David Roby & Catherine Gipe-Stewart', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (260145, 'Ulises Gonzalez', 124493,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (289111, 'Andreas Schindler & Diego Morales', 0,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (188165, 'Homer Hinojosa', 31679,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (148567, 'Jose (Joe) Barrera, Jr.', 38245,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (278813, 'Dario Fortuna', 132995,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (172034, 'Amy Nguyen', 54084,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (163706, 'Fred Webber', 78669,  'DCN', '', '', '');
INSERT INTO @MyTable VALUES (141185, 'Emerson Elliot & Jeannie Smith', 0,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (268208, 'Eddie Salcedo', 20671,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (103590, 'Chris Armata', 8502,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (139155, 'Emilio Maldonado', 36883,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (286516, 'Jose Maytorena Jr.', 20077,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (258947, 'Nancy Dixon', 107199,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (211545, 'Dan Holt', 110956,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (124666, 'Thomas Sheppard', 4007,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (101259, 'Anthony Sharrino', 2091,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (289447, 'Nick LaFountain & Matt Guerrero', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (171219, 'Marc Holbik', 72199,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (100052, 'Ashlynn Biel Elliff', 153311,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (291840, 'Alberto Pedraza', 115451,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (139777, 'Javier A. Usabiaga', 28341,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (146980, 'Pablo Enriquez Jr', 47663,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (283601, 'Art Miller', 64592,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (207390, 'Karl Kolb', 57319,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (283245, 'Ernesto Gonzalez Reyes', 140361,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (288185, 'Tim Huber', 147990,  'TAJ', 'MDE', '', '');
INSERT INTO @MyTable VALUES (104142, 'Ted Kean, Jr.', 18766,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (211534, 'Karl Seger', 109754,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (169364, 'Don Goforth', 16522,  'TBP', '', '', '');
INSERT INTO @MyTable VALUES (270210, 'Steven Ceccarelli', 63059,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (126189, 'Steve Yubeta & Liz Parra', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (121913, 'Deborah Sayers', 18931,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (272104, 'Maurice Cameron', 9340,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (260549, 'Kaleb Smith', 131067,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (211288, 'Mr. Carroll Korb', 107029,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (103701, 'Loretta Radanovic', 62175,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (209609, 'Rudy Batiz', 19468,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (104608, 'Ricardo Roiz', 64048,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (262433, 'Charles DiMaggio', 122563,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (261831, 'J. Antonio Espinosa', 114264,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (156638, 'Angela Ruiz', 787,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (194140, 'Jerry Havel', 10636,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (150161, 'Mark Miller', 47311,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (275143, 'Robert L. Diaz, Sr.', 88640,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (191833, 'Minos Athanassiadis', 1522,  'DCN', 'MDE', 'CJC', '');
INSERT INTO @MyTable VALUES (255041, 'Janeth Castro, Vicente Zambada, & Vicente Zambada, Jr.', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (144354, 'Marlene Lopez & Lance Jungmeyer', 0,  'JBL', 'BMZ', '', 'TWH');
INSERT INTO @MyTable VALUES (266871, 'Armen Avedissian & Kevin Kazarian', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (299070, 'Carlos Fuentes', 168686,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (166464, 'Ron Doucet', 13372,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (170033, 'Sarah Frey-Talley', 67977,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (127169, '', 0,  'TBP', 'BMZ', '', '');
INSERT INTO @MyTable VALUES (149334, 'James (Jim) W. Steele', 37940,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (171361, 'Louie & John Galvan', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (126385, 'Gaetan Bono', 22996,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (152397, 'Max Rusque', 3822,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (130746, 'Steve & Conchita Espinosa', 0,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (302876, 'Francisco Gerardo Velez Burciaga', 56444,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (160037, 'Steven Muro', 229016,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (135404, 'Jack Wallace', 31665,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (153502, 'Gary Goldblatt', 18795,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (135771, 'Jose (Joe) E. Garcia', 27756,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (233534, 'Giorgio Ceciarelli', 96937,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (169398, 'Tom Kioussis', 3773,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (135856, 'Frank Mesa', 63494,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (101286, 'Lisa Burke', 2120,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (169094, 'Javier Parra Jr. ', 65269,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (105784, 'Jim Heimos', 3471,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (113044, 'Steven Gill', 1388,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (211730, 'Philip Skoropat', 218597,  'TAJ', '', '', '');
INSERT INTO @MyTable VALUES (121043, 'Alma Arias', 117052,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (153697, 'Sylvain Mayrand', 25362,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (289476, 'Humberto Manuel Garcia', 38174,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (101298, 'Joanne Cipriano-Dolan', 4423,  'BMZ', '', '', '');
INSERT INTO @MyTable VALUES (140218, 'Alan Kleiman', 32814,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (152629, 'Miguel R. Gonzalez', 37620,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (170906, 'Jesse Gonzalez', 168582,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (113387, 'Paul Villa', 20793,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (165474, 'Fabiola Cuen', 65780,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (205713, 'Jorge Quintero Jr. ', 70033,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (126866, 'Jamie Strachan & Lori Bigras', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (164332, 'Estefania Naya', 175736,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (287540, 'Miguel Torres', 149481,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (324094, 'Phil Gruszka', 72369,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (337060, 'Leigh Trammel', 234134,  'AMM', 'MDE', '', '');
INSERT INTO @MyTable VALUES (117058, 'Bert & Rene Monteverde', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (211291, 'Yvonne Prinslow', 107036,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (104132, 'Charles Brown', 8138,  'JRM', '', '', 'FMS');
INSERT INTO @MyTable VALUES (264384, 'Michelle Weech', 145708,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (274751, 'Judd Johnson', 127740,  'MDE', 'CJC', '', '');
INSERT INTO @MyTable VALUES (111377, 'Harold Crawford & Keith Horder', 0,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (105510, 'Kyle Mullenix', 31210,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (164940, 'Ivan Schaefer', 40139,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (297479, 'Jaime Contreras', 20726,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (105646, 'David Haun', 3259,  'BMZ', '', '', '');
INSERT INTO @MyTable VALUES (133466, 'Bill Dietz Jr.', 34383,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (279534, 'Tim Henkel, Esq.', 133682,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (192110, 'Carlos Villa Palomares', 82192,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (259685, 'Mark Balding', 109510,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (129161, 'Harold McClarty', 16014,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (254935, 'William Elwood', 106673,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (113741, 'Steve Black', 16194,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (170470, 'Kathryn Gidley & Kathryn Klein', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (105893, 'E. Alex Flores', 57422,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (177525, 'David Bell', 136140,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (106861, 'Jake Janes', 20092,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (111948, 'Nick Hronis', 139723,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (109299, 'Hubert Nall', 33110,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (103517, 'Daniel Albinder', 4722,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (111560, 'Brett Bergmann', 1729,  'TBP', '', '', 'CAS');
INSERT INTO @MyTable VALUES (104120, 'Frank Wiecher, III', 18889,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (115342, 'Jeff Kints', 6971,  'BMZ', '', '', '');
INSERT INTO @MyTable VALUES (296980, 'Dan Edmeier', 17309,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (211325, 'George Hutchison', 96300,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (159802, 'Hagit Hecht & Adi Nov', 0,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (211302, 'Jill Fisher', 96231,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (261579, 'Matt Ventura & Paul Frietch', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (189909, 'James Cutsinger', 586,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (337061, 'Thomas Yawman', 234135,  'DCN', '', '', '');
INSERT INTO @MyTable VALUES (170086, 'Jose Luis & Alvaro Obregon', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (297414, 'Israel Estrada Torres', 163499,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (301044, 'Luis Fernando Soto & Francisco Rodriguez', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (206454, 'Francisco Rios', 95533,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (124521, 'James V. Bassetti', 27850,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (260764, 'Greg Schacher', 133155,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (172729, 'Raymond & Lynnette Keffer', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (169076, 'James Margiotta', 8450,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (106275, 'Gary H. Palmer', 43101,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (193010, 'Jenny McAfee', 64191,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (109268, 'Mike Jardina', 26587,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (168811, 'Steve Serck', 7858,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (102037, 'Dawn Arkin', 8169,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (189807, 'Jose (Rudy) R. Uresti', 45310,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (111953, 'Jon Zaninovich', 21765,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (106100, 'Julian G. Zendejas', 37690,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (281279, 'Jesus Bucio', 137595,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (197076, 'Jaime Chamberlain', 19685,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (168255, 'Juan Garcia', 78708,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (115731, 'John Russell', 40117,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (160619, 'Ciro Porricelli', 41725,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (210237, 'Michael Fernandes', 110351,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (112464, 'Joe James', 20022,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (117787, 'John Molinelli', 4827,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (104221, 'John Vena', 18309,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (102552, 'Joe Mercurio', 6575,  'CJC', '', '', 'TWH');
INSERT INTO @MyTable VALUES (279040, 'Bob Beam', 114005,  'TAJ', 'MDE', '', '');
INSERT INTO @MyTable VALUES (284503, 'Eduardo de la Vega Canelos', 36858,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (127918, 'Tim Kennedy', 16845,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (111297, 'Andrew Bianchi', 32044,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (193937, 'Steve Oldock', 12940,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (283014, 'Raul A. Zarate Selvera', 133040,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (187336, 'Guillermo Martinez', 70587,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (135708, 'Michael Elwinger', 95826,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (298698, 'Tyrone Konecny', 110969,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (287598, 'Harlan Ewert', 147468,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (233437, 'Karen Hickok', 96614,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (108839, 'Mike McGee , John & Lee Anne Oxford', 0,  'BMZ', '', '', '');
INSERT INTO @MyTable VALUES (171598, 'Chinh Nguyen', 73499,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (337062, 'Jin Ju Wilder', 38904,  'TBP', '', '', ' ');
INSERT INTO @MyTable VALUES (298790, 'Ruth Noble', 168286,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (172041, 'Pepe Vega, Jr. & Paco Vega, Jr.', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (101961, 'Rocio Vega', 78919,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (143492, 'Sami Alasmar, Jr.', 25358,  'BMZ', '', '', 'FMS');
INSERT INTO @MyTable VALUES (297359, 'Jose Duran Jr.', 96181,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (283655, 'Richard Quintero', 147042,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (281957, 'Sergio Fernando Zurita Valencia', 141970,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (131571, 'John N. Gates', 34962,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (165092, 'Jorge Vazquez', 41463,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (167143, 'Robert Goldman', 60204,  'DCN', '', '', '');
INSERT INTO @MyTable VALUES (288135, 'Robert J. McCaffery, Jr.', 148316,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (337063, 'Dan Sullivan & Matt Barrette', 0,  'DCN', '', '', '');
INSERT INTO @MyTable VALUES (125199, 'Rolando Stivalet, Jr.', 28447,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (171228, 'Louis Ledlow Jr.', 2772,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (273609, 'Lee Salins', 34676,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (301632, 'Francisco A. Feliz', 137663,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (104644, 'John Lichter', 14089,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (280813, 'Chris Lafferty', 136476,  'BMZ', '', '', '');
INSERT INTO @MyTable VALUES (105318, 'Barry R. London', 40189,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (205246, 'April Flowers', 177501,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (172163, 'Miguel Bueno', 76133,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (302031, 'Leonidez (Leo) Fernandez III', 201117,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (280447, 'George Shropshire', 164227,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (337065, 'Joe Memmesheimer', 234137,  'AMM', 'MDE', '', '');
INSERT INTO @MyTable VALUES (279849, 'Alfredo S. Velazquez', 130622,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (285996, 'Eric Shew', 219313,  'TAJ', '', '', '');
INSERT INTO @MyTable VALUES (255081, 'Darren Satsky', 106834,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (105910, 'Joe P. Murphy', 12078,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (168576, 'Mike McDonald & Ray Del Toro', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (103797, 'Denise Goodman', 45980,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (158291, 'Miguel Suarez', 20140,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (187843, 'Brian Mc Cormac', 78994,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (145912, 'Cheryl Magalas', 6886,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (105281, 'Sam Maglio, Jr.', 32521,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (162549, 'Taylor Neighbors', 36908,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (140074, 'Ward Thomas', 28989,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (120433, 'Gonzalo Avila & Peter Hayes', 0,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (101972, 'Greg Mandolini', 7941,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (106869, 'Manny Huerta', 19976,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (142217, 'Mario Macias, Jr.', 11328,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (164098, 'Jeff Long', 9975,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (211035, 'Julie Lucido & Johnna Johnson', 0,  'JBL', '', '', 'TWH');
INSERT INTO @MyTable VALUES (210205, 'Tony Apa & Justin Nelson', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (337067, 'Alejandro Larreategui', 46938,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (166764, 'Ramon Marquez', 94410,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (282159, 'Silvia Alanis Marroquin', 138946,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (145864, 'Mark A. Amendola, Esq.', 87684,  'BMZ', 'DCN', '', '');
INSERT INTO @MyTable VALUES (233446, 'Mr. Greg Langford', 111255,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (115453, 'Paul Mastronardi', 8586,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (285861, 'Mark Christos', 144668,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (193211, 'Francisco Clouthier Valdes', 37269,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (254792, 'Mike & Kim Burchett', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (145220, 'Steve McCarron & Mary Jane Fassett', 0,  'DCN', 'TBP', '', '');
INSERT INTO @MyTable VALUES (286390, 'Matt Tietz', 145635,  'TAJ', 'CDT', '', '');
INSERT INTO @MyTable VALUES (111686, 'Robert Schueller', 69766,  'TBP', '', '', 'TWH');
INSERT INTO @MyTable VALUES (109288, 'David Rose', 26598,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (211286, 'William Brown', 96007,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (146101, 'Larry Meuers', 12131,  'DCN', 'TBP', '', '');
INSERT INTO @MyTable VALUES (136684, 'Antonio Canales', 31834,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (160682, 'Tulio Garcia & Soraya Londono', 0,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (233398, 'Joel Winters', 106455,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (211740, 'Christine Robertson', 111243,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (152072, 'Kristen Reid & Emily Fragoso', 0,  'TBP', '', '', '');
INSERT INTO @MyTable VALUES (123379, 'Scott Monroe', 11797,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (170736, 'Mike Jameson', 9624,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (278864, 'Peter Politis & Brian Allen', 0,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (106488, 'Scott Murphy', 52140,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (166478, 'Tom Ciovacco, Jr.', 2181,  'BMZ', '', '', 'FMS');
INSERT INTO @MyTable VALUES (103436, 'Ron Myruski', 19211,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (166519, 'Anthony Formusa', 46653,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (163428, 'Bob Morrissey', 75860,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (262399, 'Chris Rivas', 49716,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (167820, 'Larry H. Martin', 7127,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (187284, 'Miguel & Noel Nava', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (233637, 'Marc Saracco', 158524,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (254725, 'Lorna Christie', 78151,  'CDT', 'MDE', '', '');
INSERT INTO @MyTable VALUES (105611, 'Tommy Villareal', 27964,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (164545, 'Nickey Gregory', 32221,  'TBP', '', '', 'CAS');
INSERT INTO @MyTable VALUES (115772, 'Larry Davidson', 48794,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (292416, 'John DiFeliciantonio', 18901,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (112312, 'Peter Zaferis', 19337,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (145424, 'Grant Hunt', 789,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (337068, 'Kevin Obrien', 234139,  'NCM', 'CDT', 'MDE', '');
INSERT INTO @MyTable VALUES (111742, 'Diana McClean', 89253,  'TBP', '', '', '');
INSERT INTO @MyTable VALUES (163018, 'Miguel Lopez', 20767,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (262320, 'Randy Dover', 114682,  'TAJ', 'MDE', '', '');
INSERT INTO @MyTable VALUES (101995, 'Bill Doumouras & Nick Doumouras', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (104667, 'Celida Gotsis Fujiwara & Nick Gotis', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (211527, 'Roxanne Lucas', 174597,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (209214, 'Jason Brown & Terese Brown', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (123372, 'Paul Guy', 20255,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (111635, 'Joe Esformes', 83,  'BMZ', '', '', '');
INSERT INTO @MyTable VALUES (154077, 'Marcus Hartmann', 40591,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (117182, 'Maria Lopez', 62238,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (101999, 'Deke Pappas', 8007,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (111977, 'John Pandol, Cheri Diebel, & Scott Reade', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (233763, 'Mark Auxier', 97280,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (108076, 'Steve Howard', 25836,  'TBP', '', '', 'CAS');
INSERT INTO @MyTable VALUES (127510, 'Paul Giordano', 18811,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (142410, 'Catalina Villarreal', 35367,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (108052, 'Kevin Pearce', 35200,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (270740, 'David Casarez', 124213,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (233532, 'Ronald Hanson', 96787,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (271108, 'Jay Reese', 130628,  'TAJ', 'CDT', '', '');
INSERT INTO @MyTable VALUES (126045, 'Teri Gibson', 112837,  'TBP', '', '', 'TWH');
INSERT INTO @MyTable VALUES (100956, 'Gus Pappas', 52030,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (101235, 'Peter John Condakes', 2756,  'BMZ', '', '', 'FMS');
INSERT INTO @MyTable VALUES (205028, 'Bruce Peterson', 43531,  'TBP', '', '', '');
INSERT INTO @MyTable VALUES (101866, 'Nick Balsamo', 8743,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (172974, 'Phillip Garcia', 78628,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (104166, 'Louis Penza, Jr.', 18624,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (152652, 'Ralph Schwartz', 32724,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (131769, 'Alonzo Ortiz', 36904,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (141746, 'Mary Wright Rana', 129468,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (104174, 'Joe Procacci & Mike Maxwell', 0,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (154019, 'Eric Neiman', 60157,  'JBL', '', '', 'TWH');
INSERT INTO @MyTable VALUES (153707, 'Freddy Pulido, Diana Levine & Ken Whitacre', 0,  'JBL', 'TBP', '', '');
INSERT INTO @MyTable VALUES (287105, 'Chris Damon', 19722,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (157162, 'Kristen Stevens', 91271,  'JBL', 'TBP', '', '');
INSERT INTO @MyTable VALUES (153708, 'Nancy Tucker, Tracy Wise, Alicia Calhoun & Barbara Hochman', 0,  'JBL', 'MDE', 'TBP', '');
INSERT INTO @MyTable VALUES (115015, 'Matt Brem & Larry Burk', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (115804, 'Marian Gaudry', 131084,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (258424, 'Henry Pruett', 135423,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (208049, 'Chris Elsie & Ron Sturm', 0,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (189619, 'Bill Purewal', 54681,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (158115, 'Paul Vogel', 7067,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (208289, 'Nick Delgado', 34491,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (166170, 'Mary Venegas', 143659,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (206204, 'Ryan Flaim', 90320,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (156704, 'Harris Cutler', 31159,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (209734, 'Joe Rubini', 4463,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (102627, 'Rocky Ray & Michael A. Ray', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (105518, 'Larry C. Reaves', 27002,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (171100, 'Jim DiMenna', 7173,  'TBP', '', '', 'FMS');
INSERT INTO @MyTable VALUES (211722, 'Janna Clark', 107214,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (106326, 'Jaime Hernandez, Jr.', 18803,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (198604, 'Julio Reyes', 88979,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (104709, 'Dominic P. Riggio', 47787,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (194008, 'Mike Righetti', 9054,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (168015, 'Curtis Wheat', 37874,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (106607, 'William (Bill) R. Morley', 38188,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (283619, 'Mark A. Morales', 84731,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (162112, 'Hans O. Hovda', 38214,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (337070, 'Lisa Kamphuis', 234140,  'AMM', 'MDE', '', '');
INSERT INTO @MyTable VALUES (261883, 'Wilbur Nisly', 114070,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (106556, 'John E. Gonzalez', 24886,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (128281, 'Dick Reiman & Josh Jordan', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (162630, 'Jose A. Rivera', 47563,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (172494, 'Rick Gorena', 27669,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (104786, 'Jack & Dominic Russo', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (172897, 'Aaron R. Rodriguez', 78468,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (209079, 'Rolando Nava', 92491,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (211485, 'Marty Daley', 112914,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (105471, 'Chuck Curl', 90761,  'DCN', 'TBP', '', 'TWH');
INSERT INTO @MyTable VALUES (259775, 'Terri Littlefield', 109671,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (209738, 'Tony Comella', 9498,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (118108, 'Richard Ruiz', 28054,  'TBP', '', '', 'CAS');
INSERT INTO @MyTable VALUES (190496, 'Filindo Colace', 19044,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (144794, 'R. Jason Read', 42424,  'DCN', 'TBP', '', '');
INSERT INTO @MyTable VALUES (150533, 'Mark Sergent', 8507,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (101402, 'Bruce Strock', 4555,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (256229, 'John Spaulding', 141463,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (203522, 'Domingo & Sandra Sanchez', 0,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (152290, 'Michael & Lauren Sarabian', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (158933, 'Brian Kastick', 131315,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (260648, 'Sergio Chamberlain', 19689,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (105949, 'Cary A. Hoffman', 32025,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (161579, 'Mayda Sotomayor', 8223,  'BMZ', '', '', '');
INSERT INTO @MyTable VALUES (100095, 'Tom Horwath', 111155,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (233501, 'Steve Rutledge', 109514,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (290058, 'Jaime De La Paz', 153060,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (211657, 'Terri Adair', 114095,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (255790, 'Greg Gambee', 109682,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (113670, 'Carole Shandler', 25345,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (233523, 'Mike Goodman', 159429,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (106344, 'Robert Shipley', 20427,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (129226, 'Robert M. Ruiz Jr.', 44015,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (188735, 'Luis J. Gudino', 106332,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (171608, 'Kevin Sidhu', 73560,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (106346, 'Mike Smith', 36919,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (255762, 'Troy Lundquist', 110328,  'TAJ', 'ZMC', '', '');
INSERT INTO @MyTable VALUES (112357, 'Jeff Simonian', 54396,  'DCN', '', '', 'TWH');
INSERT INTO @MyTable VALUES (211290, 'Chris Beveridge', 96018,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (211821, 'David Hanson', 122495,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (148871, 'Violet Corbett', 4966,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (191194, 'David Sherrod', 25939,  'JBL', '', '', 'CAS');
INSERT INTO @MyTable VALUES (142198, 'Debbie Gillis', 56647,  'BMZ', '', '', '');
INSERT INTO @MyTable VALUES (301216, 'Paul Ross', 31709,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (301797, 'Sergio Palala & Michael Nienkerk', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (146007, 'John Meena', 540,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (155264, 'Ernesto Maldonado', 63015,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (158037, 'John (Ted) T. Ludeman, Jr.', 4082,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (274451, 'Jared Lane', 62517,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (159843, 'Keith Slattery', 9720,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (263320, 'Joaquin Urias', 116037,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (211322, 'Rob Steverson', 96075,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (102030, 'Rob & Lisa Strube', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (126047, 'Janice Honingberg, Alan Lemke & Lori Boym', 0,  'JBL', '', '', 'TWH');
INSERT INTO @MyTable VALUES (106137, 'John S. Larson', 37872,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (172413, 'Ron Schuh', 12380,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (150037, 'Danny Mandel, Matt Mandel & Brett Burdsal', 0,  'BMZ', 'TBP', '', 'TWH');
INSERT INTO @MyTable VALUES (166500, 'Nick Dulcich', 21970,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (194278, 'Norma Myers', 38576,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (172677, 'Arnoldo Curiel', 56677,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (133194, 'Ginette Brock', 53731,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (286289, 'Ely Trujillo', 82527,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (268369, 'Arla Jamieson', 164271,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (134251, 'Chris Frod', 14283,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (197418, 'Diana Earwood', 79675,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (233633, 'Chris Swanson', 144260,  'TAJ', 'MDE', '', '');
INSERT INTO @MyTable VALUES (278161, 'Ronald Lovell', 98398,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (210074, 'Jose A. Bernal Rodriguez', 94549,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (186877, 'Astrid & Francisco Cantu', 0,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (267207, 'Joey Anderson', 175016,  'TAJ', '', '', '');
INSERT INTO @MyTable VALUES (110216, 'Owen Margolis', 8256,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (112689, 'Sally Symms & Jim Mertz', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (126889, 'John & Rick Fryman', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (122914, 'George Manos', 8527,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (106352, 'Robert Bennen, Jr.', 51598,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (191959, 'Fabian & Angie Zarate', 0,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (259881, 'Mark Myatt', 48153,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (109648, 'Paul Kazan', 6012,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (285106, 'Kenny Nova', 20052,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (120800, 'Andy Economou', 17545,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (167207, 'Mike Pharr', 2604,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (106354, 'Mark Jones', 20276,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (149843, 'Terry Fleming', 11180,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (165352, 'Marvin Y. Davis', 37839,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (290052, 'David M. Lopez', 116791,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (162361, 'Bret Erickson & Lilly Garcia', 0,  'JBL', 'TBP', '', 'CAS');
INSERT INTO @MyTable VALUES (172350, 'Clark Carkenord', 76336,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (105966, 'James M. Jones Jr.', 32108,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (151376, 'Chuck Olsen', 17921,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (252749, 'Margie Keller', 202093,  'TAJ', '', '', '');
INSERT INTO @MyTable VALUES (170798, 'Skip Consalo', 194,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (112646, 'Bob Lords', 11533,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (114986, 'Susan Powers', 11929,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (163101, 'Don Ed Holmes', 14118,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (168353, 'Frank & Ana Ramos', 0,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (153877, 'John Groh', 48863,  'JBL', 'MDE', '', '');
INSERT INTO @MyTable VALUES (106351, 'Bill Sykes', 36944,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (150146, 'Roberto D''Intino', 47974,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (166070, 'Chuck Thomas', 19332,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (251215, 'Laura Ganatos', 133857,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (211773, 'Bob Hafner', 111223,  'TAJ', '', '', '');
INSERT INTO @MyTable VALUES (290549, 'Ken Proctor', 152507,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (211500, 'Diane Prystupa', 109995,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (141303, 'Louis Iaconi, Jr. & Tom Curtis', 0,  'BMZ', '', '', 'FMS');
INSERT INTO @MyTable VALUES (102175, 'Becky Wilson & Bre Macomber', 0,  'TBP', 'CJC', '', 'TWH');
INSERT INTO @MyTable VALUES (273883, 'Scott D. Blanchard', 31858,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (101043, 'Anthony Vitrano', 39997,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (167970, 'Brett Dixon', 12170,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (207792, 'Randy Steinberg', 136520,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (113738, 'Chris Large', 40777,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (203922, 'Jo Wehage & Debbie Sabourin', 0,  'JBL', '', '', 'TWH');
INSERT INTO @MyTable VALUES (293126, 'Trey Touchstone', 25076,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (280401, 'Pedro Camacho Arvizu', 135236,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (278519, 'Richie & Paul Travers', 0,  'BMZ', '', '', 'FMS');
INSERT INTO @MyTable VALUES (106364, 'Juan Carlos Cardenas & Rod Sbragia', 0,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (171293, 'Estela Dotson & Lee Eickmeyer', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (161683, 'Vance Uchiyama', 38297,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (211725, 'Doug Heryford', 219353,  'TAJ', '', '', '');
INSERT INTO @MyTable VALUES (150285, 'Darin Puppel', 54453,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (205654, 'Heriberto Vlaminck Seidel', 36949,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (295873, 'Efrain Cuello', 55206,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (119080, 'Mark & Joel Hayes', 0,  'JBL', '', '', 'TWH');
INSERT INTO @MyTable VALUES (280139, 'Dana Davis', 87971,  'JBL', '', '', '');
INSERT INTO @MyTable VALUES (259677, 'Bruce Summers', 76844,  'DCN', '', '', '');
INSERT INTO @MyTable VALUES (189383, 'David Jaramillo', 87423,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (211378, 'Mr. Brent Irwin', 115078,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (167151, 'Jeff Oberman', 35087,  'JBL', 'TBP', ' ', '');
INSERT INTO @MyTable VALUES (145458, 'Miriam Wolk & John Toner', 0,  'JBL', ' ', '', '');
INSERT INTO @MyTable VALUES (258827, 'Brian Schumaker', 107032,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (153891, 'John Koller', 96250,  'DCN', '', '', '');
INSERT INTO @MyTable VALUES (153901, 'Philip Brickner', 0,  'TBP', '', '', '');
INSERT INTO @MyTable VALUES (137706, 'Sal Marchese', 32534,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (121459, 'Frank J. Schuster', 37796,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (113754, 'Doug LaLonde, Carrie Burrell, & Clare Bogle', 0,  'DCN', '', '', 'TWH');
INSERT INTO @MyTable VALUES (151746, 'Brian & Scott Vandervoet', 0,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (254788, 'Alejandro Toro', 107547,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (161231, 'Mike Vohland', 20597,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (115824, 'Dan Carnevale', 53200,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (105679, 'Victoriano (Victor) Trujillo', 34516,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (337072, 'Michael Carr', 234143,  'TBP', '', '', '');
INSERT INTO @MyTable VALUES (112001, 'Chance Kirk & John Zaninovich', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (287181, 'Mark Kalafut', 16179,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (139069, 'Mont Reed & Jill Kowalkowski', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (163254, 'Jerry Mata', 165236,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (143203, 'Willy Pardo & Desiree Morales', 0,  'TBP', '', '', 'CAS');
INSERT INTO @MyTable VALUES (110798, 'W. G. Frazier, Jr.', 24192,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (189555, 'Chris Wada', 91534,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (264313, 'Matthew Laux', 174471,  'TAJ', 'ZMC', '', '');
INSERT INTO @MyTable VALUES (135404, 'Jack Wallace', 31665,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (161843, 'Jill Malick', 167209,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (302478, 'Billy Foster & Lea Weng', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (211316, 'Brandi Kimberley', 107031,  'TAJ', 'KAO', 'ZMC', 'MDE');
INSERT INTO @MyTable VALUES (263419, 'Scott & Leslie Meyers', 0,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (153854, 'George & Chris Kragie', 0,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (144734, 'Matt McInerney & Randy Hause', 0,  'JBL', 'DCN', 'CJC', '');
INSERT INTO @MyTable VALUES (162214, 'Dino DiLaudo', 50790,  '', '', '', 'FMS');
INSERT INTO @MyTable VALUES (254700, 'Jim McPhail', 97439,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (254703, 'Michael Shapiro', 111230,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (254707, 'Michael Bowman', 106343,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (211772, 'John Mietus', 107043,  'TAJ', 'KAO', 'MDE', '');
INSERT INTO @MyTable VALUES (100593, 'Brian Hauge ', 37458,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (135847, 'Jessie Gunn', 173882,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (206396, 'Bobbie Lundstrom & Kiki Arana', 0,  'BMZ', '', '', 'TWH');
INSERT INTO @MyTable VALUES (152615, 'Jon Karalekas', 33928,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (323940, 'Tony Martinez', 60953,  '', '', '', 'CAS');
INSERT INTO @MyTable VALUES (263193, 'Loretta Yim', 155911,  '', '', '', 'TWH');
INSERT INTO @MyTable VALUES (114630, 'Mike Forrest', 16860,  '', '', '', 'TWH');



SELECT * FROM @MyTable ORDER BY CompanyID

DECLARE @CompanyID int, @AttentionLine varchar(200), @PersonID int, @Associate1 varchar(10), @Associate2 varchar(10), @Associate3 varchar(10), @FieldRep varchar(10)
DECLARE @Associate1ID int, @Associate2ID int, @Associate3ID int, @FieldRepID int
DECLARE @Index int, @Count int, @RecordID int

SELECT @Count = COUNT(1) FROM @MyTable
SET @Index = 0

WHILE (@Index < @Count) BEGIN

	SET @Index = @Index + 1

	SELECT @CompanyID = CompanyID,
	       @AttentionLine = AttentionLine,
		   @PersonID = PersonID,
		   @Associate1 = Associate1,
		   @Associate2 = Associate2,
		   @Associate3 = Associate3,
		   @FieldRep = FieldRep
	 FROM @MyTable
	WHERE ndx = @Index
	

	 Print 'Processing CompanyID ' + CAST(@CompanyID as varchar(10))

	 SET @Associate1ID = NULL
	 SET @Associate2ID = NULL
	 SET @Associate3ID = NULL
	 SET @FieldRepID = NULL

	 IF (@Associate1 <> '') BEGIN
		SELECT @Associate1ID = user_userid FROM users WHERE user_logon = @Associate1;
	 END
	 IF (@Associate2 <> '') BEGIN
		SELECT @Associate2ID = user_userid FROM users WHERE user_logon = @Associate2;
	 END
	 IF (@Associate3 <> '') BEGIN
		SELECT @Associate3ID = user_userid FROM users WHERE user_logon = @Associate3;
	 END
	 IF (@FieldRep <> '') BEGIN
		SELECT @FieldRepID = user_userid FROM users WHERE user_logon = @FieldRep;
	 END




	 IF EXISTS(SELECT 'x' FROM PRCompanyInfoProfile WHERE prc5_CompanyID = @CompanyID) BEGIN

		Print '- Updating'
		UPDATE PRCompanyInfoProfile
		   SET prc5_ReceiveChristmasCard = 'Y',
			   prc5_ChristmasCardAssociate1 = @Associate1ID,
			   prc5_ChristmasCardAssociate2 = @Associate2ID,
			   prc5_ChristmasCardAssociate3 = @Associate3ID,
			   prc5_ChristmasCardFieldRep = @FieldRepID,
			   prc5_UpdatedBy = 1,
			   prc5_UpdatedDate = @Start,
			   prc5_Timestamp = @Start
		 WHERE prc5_CompanyID = @CompanyID

	 END ELSE BEGIN
	    Print '- Inserting'
		EXEC usp_GetNextId 'PRCompanyInfoProfile', @RecordID output

		INSERT INTO PRCompanyInfoProfile (prc5_CompanyInfoProfileId, prc5_CompanyId, prc5_ReceiveChristmasCard, prc5_ChristmasCardAssociate1, prc5_ChristmasCardAssociate2, prc5_ChristmasCardAssociate3, prc5_ChristmasCardFieldRep,
		                                  prc5_CreatedBy, prc5_CreatedDate, prc5_UpdatedBy, prc5_UpdatedDate, prc5_Timestamp)
         VALUES (@RecordID, @CompanyID, 'Y', @Associate1ID, @Associate2ID, @Associate3ID, @FieldRepID,  1, @Start, 1, @Start, @Start);
	 END 

	 UPDATE PRAttentionLine
	    SET prattn_PersonID = @PersonID,
		    prattn_CustomLine = CASE WHEN @PersonID = 0 THEN @AttentionLine ELSE NULL END,
		    prattn_UpdatedBy = 1,
			prattn_UpdatedDate = @Start,
			prattn_Timestamp = @Start
	  WHERE prattn_CompanyID=@CompanyID
	    AND prattn_ItemCode = 'BBSICC'


END

	SELECT prc5_CompanyId, prc5_ReceiveChristmasCard, prc5_ChristmasCardAssociate1, prc5_ChristmasCardAssociate2, prc5_ChristmasCardAssociate3, prc5_ChristmasCardFieldRep FROM PRCompanyInfoProfile WHERE prc5_UpdatedBy=1 AND prc5_UpdatedDate = @Start ORDER BY prc5_CompanyId
	SELECT prattn_CompanyID, prattn_PersonID, prattn_CustomLine, prattn_AddressID FROM PRAttentionLine WHERE prattn_UpdatedBy=1 AND prattn_UpdatedDate = @Start ORDER BY prattn_CompanyID


	if (@ForCommit = 1) begin
	PRINT 'COMMITTING CHANGES'
		COMMIT
	end else begin
		PRINT 'ROLLING BACK ALL CHANGES'
		ROLLBACK TRANSACTION
	end

	END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	EXEC usp_RethrowError;
END CATCH;

PRINT ''
PRINT 'Execution End: ' + CONVERT(VARCHAR(20), GETDATE(), 100)
PRINT 'Execution Time: ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE())) + ' ms'
Go


DECLARE @RecordID int = 278
DECLARE @Start DateTime = GETDATE()

INSERT INTO PRSpecie (prspc_SpecieID, prspc_ParentID, prspc_Level, prspc_DisplayOrder, prspc_Name, prspc_CreatedBy, prspc_CreatedDate, prspc_UpdatedBy, prspc_UpdatedDate, prspc_TimeStamp) 
VALUES (@RecordID, 75, 2, 50894, 'Mahogany', -1, @Start, -1, @Start, @Start);
UPDATE PRSpecie SET prspc_DisplayOrder = 50896 WHERE prspc_SpecieID = 122
UPDATE PRSpecie SET prspc_DisplayOrder = 50897 WHERE prspc_SpecieID = 124
UPDATE PRSpecie SET prspc_DisplayOrder = 50898 WHERE prspc_SpecieID = 125
UPDATE PRSpecie SET prspc_ParentID = 278, prspc_Level=3, prspc_DisplayOrder=50899 WHERE prspc_SpecieID =121
Go
-- UPDATE PRSpecie SET prspc_DisplayOrder=50894  WHERE prspc_SpecieID = 278
--SELECT * FROM PRSpecie WHERE prspc_ParentID=75 ORDER BY prspc_DisplayOrder


INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege) VALUES ('L', 250, 'CompanySearchByFTEmployees');
Go

DECLARE @Start datetime = GETDATE()
ALTER TABLE PRCompanyCommodityAttribute DISABLE TRIGGER ALL
UPDATE PRCompanyCommodityAttribute
   SET prcca_PublishedDisplay = PublishedDisplay,
       prcca_UpdatedDate = @Start,
	   prcca_UpdatedBy = 1
 FROM (SELECT DISTINCT prcca_CommodityId as CommodityId, ISNULL(prcca_AttributeID, 0) as AttributeID, ISNULL(prcca_GrowingMethodID, 0) GrowingMethodID,
              prcca_PublishedDisplay PublishedDisplay
         FROM PRCompanyCommodityAttribute prcca WITH (NOLOCK)  
        WHERE prcca_PublishedDisplay IS NOT NULL) T1
WHERE prcca_PublishedDisplay IS NULL
  AND prcca_CommodityId = CommodityID
  AND ISNULL(prcca_AttributeID, 0) = AttributeID
  AND ISNULL(prcca_GrowingMethodID, 0) = GrowingMethodID

UPDATE PRCompanyCommodityAttribute
   SET prcca_PublishedDisplay = 'Gaichoyseeds',
       prcca_UpdatedDate = @Start,
	   prcca_UpdatedBy = 1
WHERE prcca_PublishedDisplay IS NULL
  AND prcca_CommodityId = 297
  AND ISNULL(prcca_AttributeID, 0) = 37
  AND ISNULL(prcca_GrowingMethodID, 0) = 0
ALTER TABLE PRCompanyCommodityAttribute ENABLE TRIGGER ALL


Select prcca_CompanyCommodityAttributeId, prcca_CompanyId, prcca_CommodityId, prcm_CommodityCode,
           attrb.prat_Name As AttributeName, gm.prat_Name As GrowingMethod,
			prcca_Publish = case 
			when prcca_Publish = 'Y' then 'Y' 
			when prcca_PublishWithGM = 'Y' then 'Y' 
			else '' 
			end, prcca_PublishedDisplay, prcm_PathNames 
		from PRCompanyCommodityAttribute prcca WITH (NOLOCK)  
		INNER JOIN PRCommodity prcm WITH (NOLOCK) ON prcca_CommodityId = prcm_CommodityId  
       LEFT OUTER JOIN PRAttribute AS attrb WITH (NOLOCK) ON prcca.prcca_AttributeID = attrb.prat_AttributeID 
       LEFT OUTER JOIN PRAttribute AS gm WITH (NOLOCK) ON prcca.prcca_GrowingMethodID = gm.prat_AttributeID 
WHERE prcca_UpdatedDate = @Start
   AND prcca_UpdatedBy = 1
Go

DECLARE @Start datetime = GETDATE()
UPDATE PRCommunicationLog
   SET prcoml_CompanyID = CASE eLink_EntityId WHEN '13' THEN emai_CompanyID ELSE elink_RecordID END,
       prcoml_UpdatedDate = @Start,
	   prcoml_UpdatedBy = -1
  FROM vPREmail
 WHERE prcoml_Source = 'Send TES Email'
   AND prcoml_CompanyID IS NULL
   AND prcoml_Failed = 'Y'
   AND emai_EmailAddress = prcoml_Destination
Go


DECLARE @Start datetime = GETDATE()

UPDATE PRCommodity 
	SET prcm_ParentID=434, prcm_Level = 3, prcm_PathNames='Vegetable,Root Vegetable,Horseradish',
	    prcm_PathCodes = 'V,Rootv,Hrroot', prcm_ShortDescription = 'Horseradish', prcm_FullName='Horseradish',
		prcm_Name = 'Horseradish', prcm_DisplayOrder = 4355, prcm_UpdatedDate=@Start, prcm_UpdatedBy=1
	WHERE prcm_CommodityID = 376

	

EXEC usp_PopulatePRCommodityTranslation



ALTER TABLE PRCompanyCommodityAttribute DISABLE TRIGGER ALL
UPDATE PRCompanyCommodityAttribute
    SET prcca_PublishedDisplay = 'Hrroot',
	    prcca_UpdatedBy = 1,
		prcca_UpdatedDate = @Start
  WHERE prcca_PublishedDisplay = 'Hrrootgn'

UPDATE PRCompanyCommodityAttribute
    SET prcca_PublishedDisplay = 'Koreanhrroot',
	    prcca_UpdatedBy = 1,
		prcca_UpdatedDate = @Start
  WHERE prcca_PublishedDisplay = 'Koreanhrrootgn'
ALTER TABLE PRCompanyCommodityAttribute ENABLE TRIGGER ALL


UPDATE PRListing
   SET prlst_Listing = dbo.ufn_GetListingFromCompany(prlst_CompanyID, 0, 0),
		prlst_UpdatedDate = @Start,
		prlst_UpdatedBy = 1
 WHERE prlst_CompanyID IN (SELECT prcca_CompanyID 
                             FROM PRCompanyCommodityAttribute 
						    WHERE prcca_UpdatedBy = 1
						      AND prcca_UpdatedDate = @Start);	
Go


ALTER TABLE PRCompanyProfile DISABLE TRIGGER ALL
UPDATE PRCompanyProfile 
   SET prcp_FTEmployees = CASE WHEN prcp_FTEmployees IS NULL THEN NULL WHEN prcp_FTEmployees = 0 THEN NULL ELSE prcp_FTEmployees END, 
       prcp_PTEmployees = CASE WHEN prcp_PTEmployees IS NULL THEN NULL WHEN prcp_PTEmployees = 0 THEN NULL ELSE prcp_PTEmployees END,
	   prcp_SrcBuyBrokersPct = CASE WHEN prcp_SrcBuyBrokersPct IS NULL THEN NULL WHEN prcp_SrcBuyBrokersPct = 0 THEN NULL ELSE prcp_SrcBuyBrokersPct END,
	   prcp_SrcBuyWholesalePct = CASE WHEN prcp_SrcBuyWholesalePct IS NULL THEN NULL WHEN prcp_SrcBuyWholesalePct = 0 THEN NULL ELSE prcp_SrcBuyWholesalePct END,
	   prcp_SrcBuyShippersPct = CASE WHEN prcp_SrcBuyShippersPct IS NULL THEN NULL WHEN prcp_SrcBuyShippersPct = 0 THEN NULL ELSE prcp_SrcBuyShippersPct END,
	   prcp_SrcBuyExportersPct = CASE WHEN prcp_SrcBuyExportersPct IS NULL THEN NULL WHEN prcp_SrcBuyExportersPct = 0 THEN NULL ELSE prcp_SrcBuyExportersPct END,
	   prcp_SellBrokersPct = CASE WHEN prcp_SellBrokersPct IS NULL THEN NULL WHEN prcp_SellBrokersPct = 0 THEN NULL ELSE prcp_SellBrokersPct END,
	   prcp_SellWholesalePct = CASE WHEN prcp_SellWholesalePct IS NULL THEN NULL WHEN prcp_SellWholesalePct = 0 THEN NULL ELSE prcp_SellWholesalePct END,
	   prcp_SellDomesticBuyersPct = CASE WHEN prcp_SellDomesticBuyersPct IS NULL THEN NULL WHEN prcp_SellDomesticBuyersPct = 0 THEN NULL ELSE prcp_SellDomesticBuyersPct END,
	   prcp_SellCoOpPct = CASE WHEN prcp_SellCoOpPct IS NULL THEN NULL WHEN prcp_SellCoOpPct = 0 THEN NULL ELSE prcp_SellCoOpPct END,
	   prcp_SellRetailYardPct = CASE WHEN prcp_SellRetailYardPct IS NULL THEN NULL WHEN prcp_SellRetailYardPct = 0 THEN NULL ELSE prcp_SellRetailYardPct END,
	   prcp_SellOtherPct = CASE WHEN prcp_SellOtherPct IS NULL THEN NULL WHEN prcp_SellOtherPct = 0 THEN NULL ELSE prcp_SellOtherPct END,
	   prcp_SellExportersPct = CASE WHEN prcp_SellExportersPct IS NULL THEN NULL WHEN prcp_SellExportersPct = 0 THEN NULL ELSE prcp_SellExportersPct END,
	   prcp_SellHomeCenterPct = CASE WHEN prcp_SellHomeCenterPct IS NULL THEN NULL WHEN prcp_SellHomeCenterPct = 0 THEN NULL ELSE prcp_SellHomeCenterPct END,
	   prcp_SellOfficeWholesalePct = CASE WHEN prcp_SellOfficeWholesalePct IS NULL THEN NULL WHEN prcp_SellOfficeWholesalePct = 0 THEN NULL ELSE prcp_SellOfficeWholesalePct END,
	   prcp_SellProDealerPct = CASE WHEN prcp_SellProDealerPct IS NULL THEN NULL WHEN prcp_SellProDealerPct = 0 THEN NULL ELSE prcp_SellProDealerPct END,
	   prcp_SellSecManPct = CASE WHEN prcp_SellSecManPct IS NULL THEN NULL WHEN prcp_SellSecManPct = 0 THEN NULL ELSE prcp_SellSecManPct END,
	   prcp_SellStockingWholesalePct = CASE WHEN prcp_SellStockingWholesalePct IS NULL THEN NULL WHEN prcp_SellStockingWholesalePct = 0 THEN NULL ELSE prcp_SellStockingWholesalePct END,
	   prcp_BkrCollectPct = CASE WHEN prcp_BkrCollectPct IS NULL THEN NULL WHEN prcp_BkrCollectPct = 0 THEN NULL ELSE prcp_BkrCollectPct END,
	   prcp_SrcTakePhysicalPossessionPct = CASE WHEN prcp_SrcTakePhysicalPossessionPct IS NULL THEN NULL WHEN prcp_SrcTakePhysicalPossessionPct = 0 THEN NULL ELSE prcp_SrcTakePhysicalPossessionPct END,
	   prcp_SrcBuyMillsPct = CASE WHEN prcp_SrcBuyMillsPct IS NULL THEN NULL WHEN prcp_SrcBuyMillsPct = 0 THEN NULL ELSE prcp_SrcBuyMillsPct END,
	   prcp_SrcBuyOfficeWholesalePct = CASE WHEN prcp_SrcBuyOfficeWholesalePct IS NULL THEN NULL WHEN prcp_SrcBuyOfficeWholesalePct = 0 THEN NULL ELSE prcp_SrcBuyOfficeWholesalePct END,
	   prcp_SrcBuyStockingWholesalePct = CASE WHEN prcp_SrcBuyStockingWholesalePct IS NULL THEN NULL WHEN prcp_SrcBuyStockingWholesalePct = 0 THEN NULL ELSE prcp_SrcBuyStockingWholesalePct END,
	   prcp_SrcBuyOtherPct = CASE WHEN prcp_SrcBuyOtherPct IS NULL THEN NULL WHEN prcp_SrcBuyOtherPct = 0 THEN NULL ELSE prcp_SrcBuyOtherPct END,
	   prcp_SrcBuySecManPct = CASE WHEN prcp_SrcBuySecManPct IS NULL THEN NULL WHEN prcp_SrcBuySecManPct = 0 THEN NULL ELSE prcp_SrcBuySecManPct END,
	   prcp_VolumeBoardFeetPerYear = CASE WHEN prcp_VolumeBoardFeetPerYear IS NULL THEN NULL WHEN prcp_VolumeBoardFeetPerYear = '' THEN NULL ELSE prcp_VolumeBoardFeetPerYear END,
	   prcp_VolumeTruckLoadsPerYear = CASE WHEN prcp_VolumeTruckLoadsPerYear IS NULL THEN NULL WHEN prcp_VolumeTruckLoadsPerYear = '' THEN NULL ELSE prcp_VolumeTruckLoadsPerYear END,
	   prcp_VolumeCarLoadsPerYear = CASE WHEN prcp_VolumeCarLoadsPerYear IS NULL THEN NULL WHEN prcp_VolumeCarLoadsPerYear = '' THEN NULL ELSE prcp_VolumeCarLoadsPerYear END,
	   prcp_StorageCoveredSF = CASE WHEN prcp_StorageCoveredSF IS NULL THEN NULL WHEN prcp_StorageCoveredSF = '' THEN NULL ELSE prcp_StorageCoveredSF END,
	   prcp_StorageUncoveredSF = CASE WHEN prcp_StorageUncoveredSF IS NULL THEN NULL WHEN prcp_StorageUncoveredSF = '' THEN NULL ELSE prcp_StorageUncoveredSF END,
	   prcp_RailServiceProvider1 = CASE WHEN prcp_RailServiceProvider1 IS NULL THEN NULL WHEN prcp_RailServiceProvider1 = '' THEN NULL ELSE prcp_RailServiceProvider1 END,
	   prcp_RailServiceProvider2 = CASE WHEN prcp_RailServiceProvider2 IS NULL THEN NULL WHEN prcp_RailServiceProvider2 = '' THEN NULL ELSE prcp_RailServiceProvider2 END
  FROM Company
 WHERE prcp_CompanyID = comp_CompanyID
  AND comp_PRIndustryType = 'L'
ALTER TABLE PRCompanyProfile ENABLE TRIGGER ALL
Go