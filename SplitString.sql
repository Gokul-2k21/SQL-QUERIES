/****** Object:  UserDefinedFunction [dbo].[FUN_SplitString]    Script Date: 9/21/2023 12:58:37 PM ******/
SET ANSI_NULLS ON
GO

 

SET QUOTED_IDENTIFIER ON
GO

 

CREATE FUNCTION [dbo].[FUN_SplitString]
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1)
)
RETURNS @Output TABLE (
      Item NVARCHAR(max)
)
AS
BEGIN
      DECLARE @StartIndex INT, @EndIndex INT

 

      SET @StartIndex = 1
      IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
      BEGIN
            SET @Input = @Input + @Character
      END

 

      WHILE CHARINDEX(@Character, @Input) > 0
      BEGIN
            SET @EndIndex = CHARINDEX(@Character, @Input)

            INSERT INTO @Output(Item)
            SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)

            SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
      END

 

      RETURN
END
GO