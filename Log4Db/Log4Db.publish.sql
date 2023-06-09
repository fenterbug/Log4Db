﻿/*
Deployment script for master

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
PRINT N'Creating [Logging]...';


GO
CREATE SCHEMA [Logging]
    AUTHORIZATION [dbo];


GO
PRINT N'Creating [Logging].[LogSettings]...';


GO
CREATE TABLE [Logging].[LogSettings] (
    [LoggingObject] NVARCHAR (257) NOT NULL,
    [LoggingLevel]  NVARCHAR (13)  NULL,
    CONSTRAINT [PK_LogSettings] PRIMARY KEY CLUSTERED ([LoggingObject] ASC)
);


GO
PRINT N'Creating [Logging].[LogData]...';


GO
CREATE TABLE [Logging].[LogData] (
    [User]          NVARCHAR (128)     NULL,
    [Object]        NVARCHAR (257)     NULL,
    [LineNumber]    INT                NULL,
    [Host]          NVARCHAR (128)     NULL,
    [App]           NVARCHAR (128)     NULL,
    [LogDate]       DATETIMEOFFSET (7) NULL,
    [State]         INT                NULL,
    [Severity]      INT                NULL,
    [ErrorNumber]   INT                NULL,
    [Message]       NVARCHAR (MAX)     NULL,
    [SystemMessage] NVARCHAR (MAX)     NULL
);


GO
PRINT N'Creating [Logging].[__GetLevelValue]...';


GO
CREATE FUNCTION Logging.__GetLevelValue 
(
   @LoggingLevel nVarChar(13)
)
RETURNS Integer
AS
BEGIN
   DECLARE @ResultVar Integer

   SET @ResultVar = CASE @LoggingLevel
      WHEN 'ALL' THEN 0
      WHEN 'DEBUG' THEN 1
      WHEN 'INFO' THEN 2
      WHEN 'WARN' THEN 3
      WHEN 'ERROR' THEN 4
      WHEN 'FATAL' THEN 5
      WHEN 'NONE' THEN 99
      ELSE 99
   END

   RETURN @ResultVar
END
GO
PRINT N'Creating [Logging].[__GetObjectName]...';


GO
CREATE FUNCTION [Logging].[__GetObjectName] 
(
	@ObjectId Int
)
RETURNS nVarChar(257)
AS
BEGIN
   DECLARE @FullName nVarChar(257)

   SELECT   @FullName = CASE @ObjectId
               WHEN NULL THEN '<Dynamic SQL>'
			   WHEN 0 THEN 'root'
			   ELSE OBJECT_SCHEMA_NAME(@ObjectId) + '.' + OBJECT_NAME(@ObjectId)
			END

   -- Sanity check. Debugging a dynamic sql session gave me a non-NULL @ObjectId that didn't return a name in the above statement.
   SELECT   @FullName = Coalesce (@FullName, '<Dynamic SQL>')

   RETURN @FullName

END
GO
PRINT N'Creating [Logging].[__GetLoggingLevelForObject]...';


GO
CREATE FUNCTION [Logging].[__GetLoggingLevelForObject] 
(
	@ObjectId Int = NULL
)
RETURNS nVarChar(13)
AS
BEGIN
   /*
    * Valid return values are:
	* ALL
	* DEBUG
	* INFO
	* WARN
	* ERROR
	* FATAL
	* NONE
	* UNINITIALIZED
    */
	
   DECLARE  @FullName nVarChar(256)
   DECLARE  @Result nVarChar(13)

   SET @FullName = Logging.__GetObjectName (@ObjectId)

   IF NOT EXISTS (SELECT 1 FROM Logging.LogSettings WHERE LoggingObject = @FullName)
      RETURN 'UNINITIALIZED'

   SELECT   @Result = COALESCE (LoggingLevel, 'INHERIT')
   FROM     Logging.LogSettings
   WHERE    LoggingObject = @FullName

   IF (@Result = 'INHERIT' AND @FullName <> 'root')
      RETURN Logging.__GetLoggingLevelForObject (0)

   -- Return the result of the function
   RETURN @Result

END
GO
PRINT N'Creating [Logging].[__IsLoggingLevelEnabledForObject]...';


GO
CREATE FUNCTION [Logging].[__IsLoggingLevelEnabledForObject] 
(
	@LoggingLevel nVarChar(10),
	@ObjectId Int
)
RETURNS nVarChar(13)
AS
BEGIN
   /*
    * Valid return values are:
	* YES
	* NO
	* UNINITIALIZED
    */
	
   DECLARE  @FullName nVarChar(256) = Logging.__GetObjectName (@ObjectId)
   DECLARE  @ObjectLoggingLevel nVarChar(13) = Logging.__GetLoggingLevelForObject (@ObjectId)

   IF @objectLoggingLevel = 'UNINITIALIZED'
      RETURN 'UNINITIALIZED'

   DECLARE  @ObjectLevelValue Int = Logging.__GetLevelValue (@ObjectLoggingLevel)
   DECLARE  @RequestedValue Int = Logging.__GetLevelValue (@LoggingLevel)

   IF @ObjectLevelValue <= @RequestedValue
      RETURN 'YES'

   -- Return the result of the function
   RETURN 'NO'
END
GO
PRINT N'Creating [Logging].[IsFatalEnabled]...';


GO
CREATE FUNCTION [Logging].[IsFatalEnabled] 
(
   @ObjectId Integer
)
RETURNS nVarChar(13)
AS
BEGIN
   RETURN Logging.__IsLoggingLevelEnabledForObject ('FATAL', @ObjectId)
END
GO
PRINT N'Creating [Logging].[IsErrorEnabled]...';


GO
CREATE FUNCTION [Logging].[IsErrorEnabled] 
(
   @ObjectId Integer
)
RETURNS nVarChar(13)
AS
BEGIN
   RETURN Logging.__IsLoggingLevelEnabledForObject ('ERROR', @ObjectId)
END
GO
PRINT N'Creating [Logging].[IsWarnEnabled]...';


GO
CREATE FUNCTION [Logging].[IsWarnEnabled] 
(
   @ObjectId Integer
)
RETURNS nVarChar(13)
AS
BEGIN
   RETURN Logging.__IsLoggingLevelEnabledForObject ('WARN', @ObjectId)
END
GO
PRINT N'Creating [Logging].[IsInfoEnabled]...';


GO
CREATE FUNCTION [Logging].[IsInfoEnabled] 
(
   @ObjectId Integer
)
RETURNS nVarChar(13)
AS
BEGIN
   RETURN Logging.__IsLoggingLevelEnabledForObject ('INFO', @ObjectId)
END
GO
PRINT N'Creating [Logging].[IsDebugEnabled]...';


GO
CREATE FUNCTION [Logging].[IsDebugEnabled] 
(
   @ObjectId Integer
)
RETURNS nVarChar(13)
AS
BEGIN
   RETURN Logging.__IsLoggingLevelEnabledForObject ('DEBUG', @ObjectId)
END
GO
PRINT N'Creating [Logging].[SetLoggingLevelForObject]...';


GO
CREATE PROCEDURE [Logging].[SetLoggingLevelForObject]
(
   @ObjectId Integer = NULL,
   @ObjectName nVarChar(257) = NULL,
   @NewLevel nVarChar(13)
)
AS BEGIN
   IF @ObjectName IS NULL OR @ObjectName = ''
      SET @ObjectName = Logging.__GetObjectName (@ObjectId)

   UPDATE   Logging.LogSettings
   SET      LoggingLevel = @NewLevel
   WHERE    LoggingObject = @ObjectName

   IF @@ROWCOUNT = 0
      INSERT INTO Logging.LogSettings (LoggingObject, LoggingLevel) VALUES (@ObjectName, @NewLevel)
END
GO
PRINT N'Creating [Logging].[__InitializeLoggingForObject]...';


GO
CREATE PROCEDURE [Logging].[__InitializeLoggingForObject] (
   @ObjectId Int
)
AS BEGIN
-- Always initialize for root. It won't create duplicates but it does ensure that the setting exists.
EXEC Logging.SetLoggingLevelForObject
   0
 , @NewLevel = 'NONE'

EXEC Logging.SetLoggingLevelForObject
   @ObjectId = @ObjectId
 , @NewLevel = 'INHERIT'
END
GO
PRINT N'Creating [Logging].[__DoLog]...';


GO
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


DECLARE  @FullName nVarChar(257)

-- Normalize to the object id. Logging is identified using the schema name as
-- part of the object name. The user may not have supplied the schema. This
-- compensates for such a scenario.
SET      @ObjectId = Coalesce (@ObjectId, OBJECT_ID (@ObjectName))

IF Logging.__GetLoggingLevelForObject(@ObjectId) = 'UNINITIALIZED'
   EXEC Logging.__InitializeLoggingForObject @ObjectId

IF 'YES' = Logging.__IsLoggingLevelEnabledForObject (@LogLevel, @ObjectId)
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
			 COALESCE (OBJECT_SCHEMA_NAME(@ObjectId) + '.' + OBJECT_NAME(@ObjectId), '<Dynamic SQL>') AS 'Object',
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
GO
PRINT N'Creating [Logging].[Debug]...';


GO
CREATE PROCEDURE [Logging].[Debug] (
   @ObjectId Int = NULL,
   @ObjectName sysname = NULL,
   @Message nVarChar(MAX) = NULL,
   @UseError Int = NULL
) AS BEGIN
EXEC Logging.__DoLog @ObjectId = @ObjectId, @ObjectName = @ObjectName, @UseError = @UseError, @Message = @Message, @LogLevel = 'DEBUG'
END
GO
PRINT N'Creating [Logging].[Error]...';


GO
CREATE PROCEDURE [Logging].[Error] (
   @ObjectId Int = NULL,
   @ObjectName sysname = NULL,
   @Message nVarChar(MAX) = NULL,
   @UseError Int = NULL
) AS BEGIN
EXEC Logging.__DoLog @ObjectId = @ObjectId, @ObjectName = @ObjectName, @UseError = @UseError, @Message = @Message, @LogLevel = 'ERROR'
END
GO
PRINT N'Creating [Logging].[Fatal]...';


GO
CREATE PROCEDURE [Logging].[Fatal] (
   @ObjectId Int = NULL,
   @ObjectName sysname = NULL,
   @Message nVarChar(MAX) = NULL,
   @UseError Int = NULL
) AS BEGIN
EXEC Logging.__DoLog @ObjectId = @ObjectId, @ObjectName = @ObjectName, @UseError = @UseError, @Message = @Message, @LogLevel = 'FATAL'
END
GO
PRINT N'Creating [Logging].[Warn]...';


GO
CREATE PROCEDURE [Logging].[Warn] (
   @ObjectId Int = NULL,
   @ObjectName sysname = NULL,
   @Message nVarChar(MAX) = NULL,
   @UseError Int = NULL
) AS BEGIN
EXEC Logging.__DoLog @ObjectId = @ObjectId, @ObjectName = @ObjectName, @UseError = @UseError, @Message = @Message, @LogLevel = 'WARN'
END
GO
PRINT N'Creating [Logging].[Info]...';


GO
CREATE PROCEDURE [Logging].[Info] (
   @ObjectId Int = NULL,
   @ObjectName sysname = NULL,
   @Message nVarChar(MAX) = NULL,
   @UseError Int = NULL
) AS BEGIN
EXEC Logging.__DoLog @ObjectId = @ObjectId, @ObjectName = @ObjectName, @UseError = @UseError, @Message = @Message, @LogLevel = 'INFO'
END
GO
PRINT N'Update complete.';


GO
