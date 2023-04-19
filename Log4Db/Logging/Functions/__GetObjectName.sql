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
