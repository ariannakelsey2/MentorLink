## Research Queries Optimization

### Query 1 Index

```sql
CREATE INDEX idx_Subject_Department
	ON Subject(Department);

```

### Index 1 Discussion

Without this index MYSQL performs a full table scan. Every row in the subject table is checked. If this table were to grow really big, performance would be slow. However, when we use this index the Department is found first which means only rows where the department name matches will be scanned. Imagine the Department 'Art' has 5 associated subjects in a table of 500 subjects, this would make finding them more efficient. 

### Query 1 Output

|SubjectID								| SubjectName       |
|------------------------------------|----------------------|
|631fbb74-2c51-11f1-859d-7d40ca329e80|	Norwegian history|
|6321577c-2c51-11f1-859d-7d40ca329e80|	Economic history|
|632336be-2c51-11f1-859d-7d40ca329e80|	Philippine history|
|632463f4-2c51-11f1-859d-7d40ca329e80|	Ancient history|
|6328b292-2c51-11f1-859d-7d40ca329e80|	South American history|
|632a97b0-2c51-11f1-859d-7d40ca329e80|	Humanism|
|632affb6-2c51-11f1-859d-7d40ca329e80|	Cultural history|
|6330e872-2c51-11f1-859d-7d40ca329e80|	Carthage|
|633120d0-2c51-11f1-859d-7d40ca329e80|	Biblical history|
|63361bc6-2c51-11f1-859d-7d40ca329e80|	Mexican history|
|6338a38c-2c51-11f1-859d-7d40ca329e80|	Ancient Egypt|
|6343e5c6-2c51-11f1-859d-7d40ca329e80|	Mayan history|
|63440682-2c51-11f1-859d-7d40ca329e80|	African history|
|63451540-2c51-11f1-859d-7d40ca329e80|	Indian history|
|6346a8ce-2c51-11f1-859d-7d40ca329e80|	Indonesian history|
|63494ff2-2c51-11f1-859d-7d40ca329e80|	Colombian history|
|6350a298-2c51-11f1-859d-7d40ca329e80|	German history|
|6351789e-2c51-11f1-859d-7d40ca329e80|	Pan-American history|
|63540708-2c51-11f1-859d-7d40ca329e80|	Prehistory|

### Query 2 Index

```sql
CREATE INDEX idx_Subject_Department
	ON Subject(SubjectID, Department);
    
CREATE INDEX idx_User_Subject_Type
	ON User_Subject(UserType, SubjectID, UserID);

```

### Index 2 Discussion

Without this index MYSQL scans the Subject and User_Subject tables. Since we are working with multiple tables, joins can become slow. With this index first we filter by department name and join on SubjectID. For the second Index we first filter by UserType to avoid going through rows that do not match our UserType. It then joins on SubjectID and UserID. These indexes reduce the number of rows we have to get through since we are working with multiple tables. 

### Query 2 Output

|FirstName	|LastName	|SubjectName		|UserType|
|---------|------------|----------------|-----------|
|Libby|		Bischof, PhD|	Ancient history|	Offered|

