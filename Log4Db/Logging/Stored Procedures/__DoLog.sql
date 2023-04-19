CREATE PROCEDURE [Logging].[__DoLog] (
   @ObjectId Int = NULL,
   @ObjectName sysname = NULL,
   @LogLevel nVarChar(13) = 'NONE',
   @Message nVarChar(MAX) = NULL,
   @UseError Int = NULL
) AS BEGIN

DECLARE  @errmsg nvarchar(2048),
         @severity tinyint,
         @state tinyint,
         @errno int,
         @proc sysname,
         @lineno int

-- Do this before ANYTHING so that the values don't get lost
IF @UseError = 1 BEGIN           
   SELECT @errmsg = error_message(),   @severity = error_severity(),
          @state  = error_state(),     @errno    = error_number(),
          @proc   = error_procedure(), @lineno   = error_line()
END

-- Must supply either an ObjectID or an ObjectName
IF (null = @ObjectId AND null = @ObjectName) RETURN

-- Normalize to the object id. Logging is identified using the schema name as
-- part of the object name. The user may not have supplied the schema. This
-- compensates for such a scenario.
SET      @ObjectId = Coalesce (@ObjectId, OBJECT_ID (@ObjectName))
-- And if they passed in a totally garbage object name
IF (null = @ObjectId) RETURN

IF [Logging].[__GetLoggingLevelForObject](@ObjectId) = 'UNINITIALIZED'
   EXEC [Logging].[__InitializeLoggingForObject] @ObjectId

IF 'YES' = [Logging].[__IsLoggingLevelEnabledForObject] (@LogLevel, @ObjectId)
	INSERT INTO [Logging].[LogData]
			   ([User]
			   ,[Object]
			   ,[LineNumber]
			   ,[Host]
			   ,[App]
			   ,[LogDate]
			   ,[State]
			   ,[Severity]
			   ,[ErrorNumber]
			   ,[Message]
			   ,[SystemMessage])
	SELECT   
			 suser_sname() AS 'User',
			 __GetObjectName(@ObjectID) AS 'Object',
			 CASE @UseError WHEN 1 THEN @lineno   ELSE NULL     END AS 'LineNumber',
			 host_name() AS 'Host',
			 app_name() AS 'App',
			 SYSDATETIMEOFFSET() AS 'LogDate',
			 CASE @UseError WHEN 1 THEN @state    ELSE NULL     END AS 'State',
			 CASE @UseError WHEN 1 THEN @severity ELSE NULL     END AS 'Severity',
			 CASE @UseError WHEN 1 THEN @errno    ELSE NULL     END AS 'ErrorNumber',
			 Coalesce (@Message, @errmsg) AS 'Message',
			 @errmsg AS 'SystemMessage'

END
