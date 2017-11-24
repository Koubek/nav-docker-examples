SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'SCM.ObjectMetadata' AND type = 'U')
BEGIN
    DROP TABLE [dbo].[SCM.ObjectMetadata]
END
GO

CREATE TABLE [dbo].[SCM.ObjectMetadata](
	[timestamp] [timestamp] NOT NULL,
	[Object Type] [int] NOT NULL,
	[Object ID] [int] NOT NULL,
	[Metadata] [image] NULL,
	[User Code] [image] NULL,
	[User AL Code] [image] NULL,
	[Metadata Version] [int] NOT NULL,
	[Hash] [nvarchar](32) NOT NULL,
	[Object Subtype] [nvarchar](30) NOT NULL,
	[Has Subscribers] [tinyint] NOT NULL,
	[FileName] [nvarchar](50) NOT NULL,
	[TxtFileHash] [nvarchar](32) NOT NULL,
 CONSTRAINT [SCM.ObjectMetadata$0] PRIMARY KEY CLUSTERED
(
	[Object Type] ASC,
	[Object ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


