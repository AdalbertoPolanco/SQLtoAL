/*
TableName : Table Real Name
TableDesc : Name used on Caption
TableID   :  BC Table ID
*/

DECLARE @TableName AS VARCHAR(50) = '{Table Name}';
DECLARE @TableDesc VARCHAR(100) = '{Table Description}';
DECLARE @TableID VARCHAR(10) = '{Table ID}';
--AS 

-- creation of variables 
DECLARE @strToPrint AS VARCHAR(4000);

DECLARE @ColumnName AS VARCHAR(300);
DECLARE @Key VARCHAR(2000) = '';
DECLARE @AlternateType AS INT;
DECLARE @Order int
DECLARE @ColumnLength AS INT;

--DECLARE @ColumnPrecision AS INT;

--DECLARE @ColumnScale AS INT;
 
DECLARE @TypeName AS VARCHAR(30);
PRINT 'table '+@TableID +' "' + @TableDesc + '"
{
    Caption = ''' + @TableDesc + ''';
    DataClassification = ToBeClassified;

    fields
    {
	';


DECLARE curColumns CURSOR READ_ONLY FORWARD_ONLY FOR
SELECT            C.name AS ColumnName,
                  CASE
                       WHEN t.name IN ( 'char', 'varchar', 'binary', 'varbinary', 'nchar', 'nvarchar' )
                        AND ISNULL(PK.CONSTRAINT_NAME, '') <> '' THEN 1
                       WHEN t.name IN ( 'char', 'varchar', 'binary', 'varbinary', 'nchar', 'nvarchar' )
                        AND ISNULL(PK.CONSTRAINT_NAME, '') = '' THEN 10
                       WHEN t.name IN ( 'decimal', 'numeric', 'int' )
                        AND ISNULL(PK.CONSTRAINT_NAME, '') <> '' THEN 2
                       WHEN t.name IN ( 'decimal', 'numeric', 'int' )
                        AND ISNULL(PK.CONSTRAINT_NAME, '') = '' THEN 20
                       ELSE 0 END AS AlternateType,
                  C.length AS ColumnLength,colorder
  FROM            syscolumns C
 INNER JOIN       systypes t
    ON C.xtype        = t.xtype
   AND C.usertype     = t.usertype
 INNER JOIN       sysobjects o
    ON C.id           = o.id
  LEFT OUTER JOIN (   SELECT K.TABLE_NAME,
                             K.COLUMN_NAME,
                             K.CONSTRAINT_NAME
                        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS C
                        JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS K
                          ON C.TABLE_NAME         = K.TABLE_NAME
                         AND C.CONSTRAINT_CATALOG = K.CONSTRAINT_CATALOG
                         AND C.CONSTRAINT_SCHEMA  = K.CONSTRAINT_SCHEMA
                         AND C.CONSTRAINT_NAME    = K.CONSTRAINT_NAME
                       WHERE C.CONSTRAINT_TYPE = 'PRIMARY KEY') PK
    ON PK.TABLE_NAME  = o.name
   AND PK.COLUMN_NAME = C.name
 WHERE            C.id = OBJECT_ID(N'' + @TableName + '')
 ORDER BY C.colid;


OPEN curColumns;
FETCH NEXT FROM curColumns
 INTO @ColumnName,
      @AlternateType,
      @ColumnLength,@Order;
      

WHILE (@@FETCH_STATUS = 0)
BEGIN
    DECLARE @Tipo VARCHAR(30);
    SET @strToPrint = @ColumnName;
    IF @AlternateType = 1
    BEGIN
        SET @Tipo = ' ;Code[' + CAST(@ColumnLength AS VARCHAR) + '])';
        SET @Key = @Key + CASE
                               WHEN @Key = '' THEN '"' + @ColumnName + '"'
                               ELSE ',' + '"' + @ColumnName + '"' END;
    END;
    IF @AlternateType = 10
    BEGIN
        SET @Tipo = ' ;Text[' + CAST(@ColumnLength AS VARCHAR) + '])';
    END;
    IF @AlternateType = 2
    BEGIN
        SET @Tipo = ' ; Decimal';
        SET @Key = @Key + CASE
                               WHEN @Key = '' THEN '"' + @ColumnName + '"'
                               ELSE ',' + '"' + @ColumnName + '"' END;
    END;
    IF @AlternateType = 20
    BEGIN
        SET @Tipo = ' ; Decimal';
    END;

    IF @AlternateType = 0
    BEGIN
        SET @Tipo = ' Type Error';
    END;
    SET @strToPrint
        = '        field('+ CAST(@Order AS VARCHAR(3)) +'; "' + @ColumnName + '"; ' + @Tipo + '
        {
            Caption = ''' + REPLACE(@ColumnName, '_', ' ')
          + ''';
            DataClassification = ToBeClassified;
        }
'   ;

    PRINT @strToPrint;

    FETCH NEXT FROM curColumns
     INTO @ColumnName,
          @AlternateType,
          @ColumnLength,@Order;

END;

CLOSE curColumns;
DEALLOCATE curColumns;
IF @Key <> ''
    PRINT '
    keys
    {
        key(PK; ' + @Key + ')
        {
            Clustered = true;
        }
    }

}'  ;




