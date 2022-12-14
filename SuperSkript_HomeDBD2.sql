USE [master]
GO
/****** Object:  Database [HomeDBD2]    Script Date: 28.10.2022 11:14:25 ******/
CREATE DATABASE [HomeDBD2]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'HomeDBD2', FILENAME = N'C:\SQL-Kurs\DB\HomeDBD\HomeDBD2.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 LOG ON 
( NAME = N'HomeDBD2_log', FILENAME = N'C:\SQL-Kurs\DB\HomeDBD\HomeDBD2_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [HomeDBD2] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [HomeDBD2].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [HomeDBD2] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [HomeDBD2] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [HomeDBD2] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [HomeDBD2] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [HomeDBD2] SET ARITHABORT OFF 
GO
ALTER DATABASE [HomeDBD2] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [HomeDBD2] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [HomeDBD2] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [HomeDBD2] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [HomeDBD2] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [HomeDBD2] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [HomeDBD2] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [HomeDBD2] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [HomeDBD2] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [HomeDBD2] SET  DISABLE_BROKER 
GO
ALTER DATABASE [HomeDBD2] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [HomeDBD2] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [HomeDBD2] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [HomeDBD2] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [HomeDBD2] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [HomeDBD2] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [HomeDBD2] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [HomeDBD2] SET RECOVERY FULL 
GO
ALTER DATABASE [HomeDBD2] SET  MULTI_USER 
GO
ALTER DATABASE [HomeDBD2] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [HomeDBD2] SET DB_CHAINING OFF 
GO
ALTER DATABASE [HomeDBD2] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [HomeDBD2] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [HomeDBD2] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [HomeDBD2] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [HomeDBD2] SET QUERY_STORE = OFF
GO
USE [HomeDBD2]
GO
/****** Object:  User [AndreasSchreiber]    Script Date: 28.10.2022 11:14:25 ******/
CREATE USER [AndreasSchreiber] FOR LOGIN [Andreas] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  UserDefinedFunction [dbo].[sf_GetAge]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <25.101.2022>
-- Description:	<Gegeben alter for ein person>
-- =============================================
CREATE   FUNCTION [dbo].[sf_GetAge]
(
	-- parameters for the function
	@PersonID int
)
RETURNS int
AS
BEGIN
	-- Declare  return variable
	DECLARE @Age int;
	DECLARE @Heute date;
	SET @Heute = GETDATE();
	DECLARE @Gebdat date;

	-- T-SQL statements to compute the return value 
	SELECT  @Gebdat = GebDat FROM dbo.tb_Person
	WHERE PersonID = @PersonID

	IF (MONTH(@GebDat) > MONTH(@Heute)) -- Geburtstag erst später
		SET @Age = DATEDIFF(YEAR, @GebDat, @Heute) - 1 -- ist noch nich so alt

	ELSE IF (MONTH(@GebDat) = MONTH(@Heute) AND DAY(@GebDat) > DAY(@Heute))
		SET @Age = DATEDIFF(YEAR, @GebDat, @Heute) - 1 -- ist noch nich so alt

	ELSE SET @Age = DATEDIFF(YEAR, @GebDat, @Heute);
	
	-- Return the result of the function
	RETURN @Age;

END
GO
/****** Object:  UserDefinedFunction [dbo].[sf_GetPercentageKategorie]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <26.101.202>
-- Description:	<Geben percent für ein kategorie>
-- =============================================
CREATE      FUNCTION [dbo].[sf_GetPercentageKategorie]
(
   ----Input parameters
	@PersonID int,
	@KostenArtID int,
	@datum date

)
RETURNS Float
AS
BEGIN
	-- Declare the return variable 
	DECLARE @ResultPercent Float,
		@SumAus Float,
		@SumEin Float,
		@KostenartKategorie nvarchar(20)

     ----find  KostenKategorie
	SELECT   @KostenartKategorie = dbo.tb_KostenKategorie.KostenKategorie
	FROM    dbo.tb_KostenArt INNER JOIN
            dbo.tb_KostenKategorie ON dbo.tb_KostenArt.KostenKategorieID = dbo.tb_KostenKategorie.KostenKategorieID
	WHERE   (dbo.tb_KostenArt.KostenArtID = @KostenArtID )

	----calculate sum with sum function
	SET @SumAus = dbo.sf_sumofausgabeperkategorie(@PersonID,@datum,@KostenartKategorie)
	SET @SumEin = dbo.sf_SumofEingaben(@PersonID,@datum)

	--get percentage
	SET @ResultPercent = Round(((@SumAus/@SumEin)*100), 2)
	
	-- Return the result of the function
	RETURN @ResultPercent

END
GO
/****** Object:  UserDefinedFunction [dbo].[sf_istKostenarterlaubtab18]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE   FUNCTION [dbo].[sf_istKostenarterlaubtab18]
(
    ---input parameter
	@KostenartID int
)
RETURNS bit
AS
BEGIN
	---Declare result variable
	DECLARE @Result bit

	---TSQL Statement to calculate result
	SELECT @Result = dbo.tb_KostenArt.Ab18 
	FROM	tb_KostenArt 
	WHERE KostenArtID = @KostenartID

	---result--
	RETURN @Result

END
GO
/****** Object:  UserDefinedFunction [dbo].[sf_SumofAusgaben]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <25.10.2022>
-- Description:	<Geben sum of alle Ausgaben>
-- =============================================
CREATE   FUNCTION [dbo].[sf_SumofAusgaben]
(
	-- parameters for the function 
		@PersonID int,
	    @Datum date
)
RETURNS int
AS
BEGIN
	-- Declare the return variable 
	DECLARE @Sum int

	--  T-SQL statements to compute the return value 
	SELECT @Sum = SUM([Sume]) FROM dbo.tb_Ausgaben
    WHERE PersonID = @PersonID and MONTH(@Datum) = MONTH(Datum)

	-- Return the result of the function
	RETURN @Sum

END
GO
/****** Object:  UserDefinedFunction [dbo].[sf_sumofausgabeperkategorie]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE     FUNCTION [dbo].[sf_sumofausgabeperkategorie]
(
    ---input parameters--
	@PersonID int,
	@Datum date,
	@Kostenkategorie nvarchar(20)
)
RETURNS int
AS
BEGIN
	---declare result variables--
	DECLARE @Sum int

	---T-SQL statement to compute value 
	SELECT @Sum = Sum(dbo.tb_Ausgaben.Sume)
	FROM   dbo.tb_Person INNER JOIN
           dbo.tb_Ausgaben ON dbo.tb_Person.PersonID = dbo.tb_Ausgaben.PersonID INNER JOIN
           dbo.tb_KostenArt ON dbo.tb_Ausgaben.KostenArtID = dbo.tb_KostenArt.KostenArtID INNER JOIN
           dbo.tb_KostenKategorie ON dbo.tb_KostenArt.KostenKategorieID = dbo.tb_KostenKategorie.KostenKategorieID
	WHERE  (dbo.tb_KostenKategorie.KostenKategorie = @Kostenkategorie) AND (dbo.tb_Person.PersonID = @PersonID) 
	AND (MONTH(dbo.tb_Ausgaben.Datum) = MONTH(@Datum))
	
	---Result--
	RETURN @Sum
END
GO
/****** Object:  UserDefinedFunction [dbo].[sf_SumofEingaben]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <25.10.2022>
-- Description:	<Geben sum of alle Eingaben>
-- =============================================
CREATE FUNCTION [dbo].[sf_SumofEingaben] 
(
	-- parameters for the function
	@PersonID int,
	@Datum date
)
RETURNS int
AS
BEGIN
	-- Declare return variable 
	DECLARE @Sum int

	-- T-SQL statements to compute the return value 
	SELECT @Sum = SUM([Sume]) FROM dbo.tb_Eingaben
    WHERE PersonID = @PersonID and MONTH(@Datum) = MONTH(Datum)

	-- Return the result of the function
	RETURN @Sum

END
GO
/****** Object:  UserDefinedFunction [dbo].[sf_Zeitstempel]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION  [dbo].[sf_Zeitstempel]
(
	
)
RETURNS char(18)
AS
BEGIN
	RETURN FORMAT(GETDATE(), 'yyyyMMdd-HHmmssfff');

END
GO
/****** Object:  Table [dbo].[tb_Person]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_Person](
	[PersonID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](30) NOT NULL,
	[Nachname] [nvarchar](30) NOT NULL,
	[GebDat] [date] NOT NULL,
	[VerwandID] [int] NULL,
	[GeschlechtID] [int] NULL,
	[FamilieID] [int] NULL,
 CONSTRAINT [PK_tb_Person] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_Ausgaben]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_Ausgaben](
	[AusgabenID] [tinyint] IDENTITY(1,1) NOT NULL,
	[Datum] [date] NOT NULL,
	[KostenArtID] [int] NOT NULL,
	[PersonID] [int] NOT NULL,
	[Sume] [money] NOT NULL,
	[Kommentar] [text] NULL,
 CONSTRAINT [PK_Ausgaben] PRIMARY KEY CLUSTERED 
(
	[AusgabenID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_KostenArt]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_KostenArt](
	[KostenArtID] [int] IDENTITY(1,1) NOT NULL,
	[KostenKategorieID] [int] NOT NULL,
	[KostenArt] [nvarchar](30) NOT NULL,
	[Ab18] [bit] NULL,
 CONSTRAINT [PK_tb_KostenArt] PRIMARY KEY CLUSTERED 
(
	[KostenArtID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_KostenKategorie]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_KostenKategorie](
	[KostenKategorieID] [int] IDENTITY(1,1) NOT NULL,
	[KostenKategorie] [nvarchar](30) NOT NULL,
	[PercentageGrenze] [float] NULL,
 CONSTRAINT [PK_tb_KostenKategorie] PRIMARY KEY CLUSTERED 
(
	[KostenKategorieID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[View_KostenArtCount]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_KostenArtCount]
AS
SELECT        dbo.tb_Person.Name, COUNT(dbo.tb_KostenArt.KostenArt) AS Count
FROM            dbo.tb_KostenKategorie INNER JOIN
                         dbo.tb_KostenArt ON dbo.tb_KostenKategorie.KostenKategorieID = dbo.tb_KostenArt.KostenKategorieID INNER JOIN
                         dbo.tb_Ausgaben ON dbo.tb_KostenArt.KostenArtID = dbo.tb_Ausgaben.KostenArtID INNER JOIN
                         dbo.tb_Person ON dbo.tb_Ausgaben.PersonID = dbo.tb_Person.PersonID
WHERE        (dbo.tb_KostenArt.KostenArt = 'Haushalt')
GROUP BY dbo.tb_Person.Name
GO
/****** Object:  UserDefinedFunction [dbo].[tf_KostenArtCount]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE    FUNCTION [dbo].[tf_KostenArtCount] 
(	
	--  parameters for the function
	@KostenArt nvarchar(30)
	
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT dbo.tb_Person.Name, COUNT(dbo.tb_KostenArt.KostenArt) AS Count
	FROM   dbo.tb_KostenKategorie INNER JOIN
		dbo.tb_KostenArt ON dbo.tb_KostenKategorie.KostenKategorieID = dbo.tb_KostenArt.KostenKategorieID INNER JOIN
		dbo.tb_Ausgaben ON dbo.tb_KostenArt.KostenArtID = dbo.tb_Ausgaben.KostenArtID INNER JOIN
		dbo.tb_Person ON dbo.tb_Ausgaben.PersonID = dbo.tb_Person.PersonID
	WHERE (dbo.tb_KostenArt.KostenArt = @KostenArt)
	GROUP BY dbo.tb_Person.Name
)
GO
/****** Object:  View [dbo].[View_Ausgabe_per_KategoriePerson]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Ausgabe_per_KategoriePerson]
AS
SELECT        TOP (100) PERCENT dbo.tb_Person.Name, dbo.tb_Ausgaben.Datum, dbo.tb_KostenArt.KostenArt, dbo.tb_Ausgaben.Sume
FROM            dbo.tb_Person LEFT OUTER JOIN
                         dbo.tb_Ausgaben ON dbo.tb_Person.PersonID = dbo.tb_Ausgaben.PersonID INNER JOIN
                         dbo.tb_KostenArt ON dbo.tb_Ausgaben.KostenArtID = dbo.tb_KostenArt.KostenArtID INNER JOIN
                         dbo.tb_KostenKategorie ON dbo.tb_KostenArt.KostenKategorieID = dbo.tb_KostenKategorie.KostenKategorieID
WHERE        (dbo.tb_KostenKategorie.KostenKategorie = N'FixKosten') AND (dbo.tb_Person.PersonID = 1) AND (MONTH(dbo.tb_Ausgaben.Datum) = 10)
ORDER BY dbo.tb_Ausgaben.Datum DESC, dbo.tb_KostenArt.KostenArt
GO
/****** Object:  Table [dbo].[tb_GehaltArt]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_GehaltArt](
	[GehaltArtID] [int] IDENTITY(1,1) NOT NULL,
	[GehaltKategorieID] [int] NOT NULL,
	[GehaltArt] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tb_GehaltArt] PRIMARY KEY CLUSTERED 
(
	[GehaltArtID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_Eingaben]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_Eingaben](
	[EingabenID] [int] NOT NULL,
	[Datum] [date] NOT NULL,
	[GehaltArtID] [int] NOT NULL,
	[PersonID] [int] NOT NULL,
	[Sume] [money] NOT NULL,
 CONSTRAINT [PK_tb_Eingaben] PRIMARY KEY CLUSTERED 
(
	[EingabenID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_GehaltKategorie]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_GehaltKategorie](
	[GehaltKategorieID] [int] IDENTITY(1,1) NOT NULL,
	[GehaltKategorie] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tb_GehaltKategorie] PRIMARY KEY CLUSTERED 
(
	[GehaltKategorieID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[View_Eingabe_per_KategoriePerson]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Eingabe_per_KategoriePerson]
AS
SELECT        TOP (100) PERCENT dbo.tb_Person.Name, dbo.tb_Eingaben.Datum, dbo.tb_GehaltArt.GehaltArt, dbo.tb_Eingaben.Sume
FROM            dbo.tb_Person LEFT OUTER JOIN
                         dbo.tb_Eingaben ON dbo.tb_Person.PersonID = dbo.tb_Eingaben.PersonID INNER JOIN
                         dbo.tb_GehaltArt ON dbo.tb_Eingaben.GehaltArtID = dbo.tb_GehaltArt.GehaltArtID INNER JOIN
                         dbo.tb_GehaltKategorie ON dbo.tb_GehaltArt.GehaltKategorieID = dbo.tb_GehaltKategorie.GehaltKategorieID
WHERE        (dbo.tb_GehaltKategorie.GehaltKategorie = N'FixGehalt') AND (dbo.tb_Person.PersonID = 1)
ORDER BY dbo.tb_Eingaben.Datum, dbo.tb_GehaltArt.GehaltArt
GO
/****** Object:  View [dbo].[View_Ausgabe_per_MonthPerson]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Ausgabe_per_MonthPerson]
AS
SELECT        TOP (100) PERCENT dbo.tb_Person.Name, dbo.tb_Ausgaben.Datum, dbo.tb_KostenKategorie.KostenKategorie, dbo.tb_KostenArt.KostenArt, dbo.tb_Ausgaben.Sume
FROM            dbo.tb_Person LEFT OUTER JOIN
                         dbo.tb_Ausgaben ON dbo.tb_Person.PersonID = dbo.tb_Ausgaben.PersonID INNER JOIN
                         dbo.tb_KostenArt ON dbo.tb_Ausgaben.KostenArtID = dbo.tb_KostenArt.KostenArtID INNER JOIN
                         dbo.tb_KostenKategorie ON dbo.tb_KostenArt.KostenKategorieID = dbo.tb_KostenKategorie.KostenKategorieID
WHERE        (MONTH(dbo.tb_Ausgaben.Datum) = 10) AND (dbo.tb_Person.PersonID = 1)
ORDER BY dbo.tb_Ausgaben.Datum, dbo.tb_KostenKategorie.KostenKategorie, dbo.tb_KostenArt.KostenArt
GO
/****** Object:  View [dbo].[View_Eingabe_per_MonthPerson]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Eingabe_per_MonthPerson]
AS
SELECT        TOP (100) PERCENT dbo.tb_Person.Name, dbo.tb_Eingaben.Datum, dbo.tb_GehaltKategorie.GehaltKategorie, dbo.tb_GehaltArt.GehaltArt, dbo.tb_Eingaben.Sume
FROM            dbo.tb_Person LEFT OUTER JOIN
                         dbo.tb_Eingaben ON dbo.tb_Person.PersonID = dbo.tb_Eingaben.PersonID INNER JOIN
                         dbo.tb_GehaltArt ON dbo.tb_Eingaben.GehaltArtID = dbo.tb_GehaltArt.GehaltArtID INNER JOIN
                         dbo.tb_GehaltKategorie ON dbo.tb_GehaltArt.GehaltKategorieID = dbo.tb_GehaltKategorie.GehaltKategorieID
WHERE        (MONTH(dbo.tb_Eingaben.Datum) = 10) AND (dbo.tb_Person.PersonID = 1)
ORDER BY dbo.tb_Eingaben.Datum, dbo.tb_GehaltKategorie.GehaltKategorie, dbo.tb_GehaltArt.GehaltArt
GO
/****** Object:  UserDefinedFunction [dbo].[tf_Ausgabe_per_KategoriePerson]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <26.10.2022>
-- Description:	<Die Tabellenwertfunktion geben liste von alle ausgaben für ein monat, ein person und ein Kategorie>
-- =============================================
CREATE    FUNCTION [dbo].[tf_Ausgabe_per_KategoriePerson] 
(	
	@PersonID int,
	@Kategorie nvarchar(20)
)
RETURNS TABLE 
AS
RETURN 
(
	
	SELECT TOP (100) PERCENT 
		   dbo.tb_Person.Name, dbo.tb_Person.Nachname, dbo.tb_Ausgaben.Datum, dbo.tb_KostenArt.KostenArt, dbo.tb_Ausgaben.Sume
	FROM   dbo.tb_Person LEFT OUTER JOIN
           dbo.tb_Ausgaben ON dbo.tb_Person.PersonID = dbo.tb_Ausgaben.PersonID INNER JOIN
           dbo.tb_KostenArt ON dbo.tb_Ausgaben.KostenArtID = dbo.tb_KostenArt.KostenArtID INNER JOIN
           dbo.tb_KostenKategorie ON dbo.tb_KostenArt.KostenKategorieID = dbo.tb_KostenKategorie.KostenKategorieID
	WHERE  (dbo.tb_KostenKategorie.KostenKategorie = @Kategorie) AND (dbo.tb_Person.PersonID = @PersonID)
	ORDER BY dbo.tb_Ausgaben.Datum, dbo.tb_KostenArt.KostenArt DESC
)
GO
/****** Object:  UserDefinedFunction [dbo].[tf_Eingabe_per_KategoriePerson]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   FUNCTION [dbo].[tf_Eingabe_per_KategoriePerson] 
(	
	@PersonID int,
	@Kategorie nvarchar(20)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT  TOP (100) PERCENT
	dbo.tb_Person.Name, dbo.tb_Person.Nachname, dbo.tb_Eingaben.Datum, dbo.tb_GehaltArt.GehaltArt, dbo.tb_Eingaben.Sume
	FROM   dbo.tb_Person INNER JOIN
           dbo.tb_Eingaben ON dbo.tb_Person.PersonID = dbo.tb_Eingaben.PersonID INNER JOIN
           dbo.tb_GehaltArt ON dbo.tb_Eingaben.GehaltArtID = dbo.tb_GehaltArt.GehaltArtID INNER JOIN
           dbo.tb_GehaltKategorie ON dbo.tb_GehaltArt.GehaltKategorieID = dbo.tb_GehaltKategorie.GehaltKategorieID
	WHERE (dbo.tb_GehaltKategorie.GehaltKategorie =@Kategorie) AND (dbo.tb_Person.PersonID = @PersonID)
ORDER BY dbo.tb_Eingaben.Datum DESC
)
GO
/****** Object:  UserDefinedFunction [dbo].[tf_Eingabe_per_MonthPerson]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   FUNCTION [dbo].[tf_Eingabe_per_MonthPerson]  
(	
	@PersonID int,
	@Datum date
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP (100) PERCENT 
	dbo.tb_Person.Name, dbo.tb_Person.Nachname, dbo.tb_Eingaben.Datum, dbo.tb_Eingaben.Sume, dbo.tb_GehaltArt.GehaltArt
	FROM  dbo.tb_Person INNER JOIN
          dbo.tb_Eingaben ON dbo.tb_Person.PersonID = dbo.tb_Eingaben.PersonID INNER JOIN
          dbo.tb_GehaltArt ON dbo.tb_Eingaben.GehaltArtID = dbo.tb_GehaltArt.GehaltArtID INNER JOIN
          dbo.tb_GehaltKategorie ON dbo.tb_GehaltArt.GehaltKategorieID = dbo.tb_GehaltKategorie.GehaltKategorieID
	WHERE(MONTH(dbo.tb_Eingaben.Datum) = 10) AND (dbo.tb_Person.PersonID = 1)
	ORDER BY dbo.tb_Eingaben.Datum DESC
)
GO
/****** Object:  UserDefinedFunction [dbo].[tf_Ausgabe_Datumvon_undbis]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <26.10.2022>
-- Description:	<Die Funktion geben alle ausgaben Zweischen Zwei Datum>
-- =============================================
CREATE   FUNCTION [dbo].[tf_Ausgabe_Datumvon_undbis] 
(	
	@PersonID int,
	@Datumvon date,
	@Datumbis date
)
RETURNS TABLE 
AS
RETURN 
(
	
	SELECT  TOP (100) PERCENT dbo.tb_Person.Name, 
			dbo.tb_Ausgaben.Datum,
			dbo.tb_KostenKategorie.KostenKategorie,
			dbo.tb_KostenArt.KostenArt,
			dbo.tb_Ausgaben.Sume 
	FROM    dbo.tb_Person LEFT OUTER JOIN
            dbo.tb_Ausgaben ON dbo.tb_Person.PersonID = dbo.tb_Ausgaben.PersonID INNER JOIN
            dbo.tb_KostenArt ON dbo.tb_Ausgaben.KostenArtID = dbo.tb_KostenArt.KostenArtID INNER JOIN
            dbo.tb_KostenKategorie ON dbo.tb_KostenArt.KostenKategorieID = dbo.tb_KostenKategorie.KostenKategorieID
	WHERE  (dbo.tb_Ausgaben.Datum BETWEEN  @DatumVon AND @DatumBis ) AND (dbo.tb_Person.PersonID = @PersonID)
	ORDER BY dbo.tb_Ausgaben.Datum, dbo.tb_KostenKategorie.KostenKategorie, dbo.tb_KostenArt.KostenArt
)
GO
/****** Object:  UserDefinedFunction [dbo].[tf_Balance_perPersonDatumVonBis]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <27.10.2022>
-- Description:	<Alle eingabe und ausgabe für ein person>
-- =============================================
CREATE   FUNCTION [dbo].[tf_Balance_perPersonDatumVonBis]
(	
----input parameters--
	@PersonID int,
	@DatumVon date,
	@Datumbis date
)
RETURNS TABLE 
AS
RETURN 
(
	-- SELECT statement with parameter references here
	SELECT dbo.tb_Person.Nachname, dbo.tb_Person.Name,  
	   dbo.tb_Ausgaben.Datum AS Datum,
	   dbo.tb_KostenKategorie.KostenKategorie, dbo.tb_KostenArt.KostenArt, 
	   'Ausgabe' AS ART,
	   --dbo.tb_Ausgaben.Sume,
	   '- ' + CONVERT(varchar(10),dbo.tb_Ausgaben.Sume) AS 'Summe mit Zeichen' 
FROM dbo.tb_Person INNER JOIN
    dbo.tb_Ausgaben ON dbo.tb_Person.PersonID = dbo.tb_Ausgaben.PersonID INNER JOIN
    dbo.tb_KostenArt ON dbo.tb_Ausgaben.KostenArtID = dbo.tb_KostenArt.KostenArtID INNER JOIN
    dbo.tb_KostenKategorie ON dbo.tb_KostenArt.KostenKategorieID = dbo.tb_KostenKategorie.KostenKategorieID
WHERE dbo.tb_Person.PersonID = @PersonID
AND dbo.tb_Ausgaben.Datum BETWEEN @DatumVon AND @Datumbis

UNION

SELECT dbo.tb_Person.Nachname, dbo.tb_Person.Name, 
	   dbo.tb_Eingaben.Datum, 
	   dbo.tb_GehaltKategorie.GehaltKategorie, dbo.tb_GehaltArt.GehaltArt,
	   'Eingabe',
	   --dbo.tb_Eingaben.Sume,
	   '+ ' +CONVERT(varchar(10),dbo.tb_Eingaben.Sume)
FROM dbo.tb_Person INNER JOIN
    dbo.tb_Eingaben ON dbo.tb_Person.PersonID = dbo.tb_Eingaben.PersonID INNER JOIN
    dbo.tb_GehaltArt ON dbo.tb_Eingaben.GehaltArtID = dbo.tb_GehaltArt.GehaltArtID INNER JOIN
    dbo.tb_GehaltKategorie ON dbo.tb_GehaltArt.GehaltKategorieID = dbo.tb_GehaltKategorie.GehaltKategorieID
WHERE dbo.tb_Person.PersonID = @PersonID
AND dbo.tb_Eingaben.Datum BETWEEN @DatumVon AND @Datumbis
)
GO
/****** Object:  Table [dbo].[tb_AusgabeMeldung]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_AusgabeMeldung](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EditOn] [date] NOT NULL,
	[Meldung] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_Familie]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_Familie](
	[FamilieID] [int] IDENTITY(1,1) NOT NULL,
	[Familie] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_tb_Familie] PRIMARY KEY CLUSTERED 
(
	[FamilieID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_Geschlecth]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_Geschlecth](
	[GeschlecthID] [int] IDENTITY(1,1) NOT NULL,
	[Geschlecth] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_tb_Geschlecth] PRIMARY KEY CLUSTERED 
(
	[GeschlecthID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_Verwand]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_Verwand](
	[VerwandID] [int] IDENTITY(1,1) NOT NULL,
	[Verwand] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_tb_Verwand] PRIMARY KEY CLUSTERED 
(
	[VerwandID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_Eingaben]    Script Date: 28.10.2022 11:14:25 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_tb_Eingaben] ON [dbo].[tb_Eingaben]
(
	[EingabenID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIX_tb_GehaltArt]    Script Date: 28.10.2022 11:14:25 ******/
CREATE UNIQUE NONCLUSTERED INDEX [NonClusteredIX_tb_GehaltArt] ON [dbo].[tb_GehaltArt]
(
	[GehaltArtID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIX_tb_GehaltKategorie]    Script Date: 28.10.2022 11:14:25 ******/
CREATE UNIQUE NONCLUSTERED INDEX [NonClusteredIX_tb_GehaltKategorie] ON [dbo].[tb_GehaltKategorie]
(
	[GehaltKategorieID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIX_tb_Geschlecth]    Script Date: 28.10.2022 11:14:25 ******/
CREATE UNIQUE NONCLUSTERED INDEX [NonClusteredIX_tb_Geschlecth] ON [dbo].[tb_Geschlecth]
(
	[GeschlecthID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIX_tb_KostenArt]    Script Date: 28.10.2022 11:14:25 ******/
CREATE UNIQUE NONCLUSTERED INDEX [NonClusteredIX_tb_KostenArt] ON [dbo].[tb_KostenArt]
(
	[KostenArtID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIX_tb_KostenKategorie]    Script Date: 28.10.2022 11:14:25 ******/
CREATE UNIQUE NONCLUSTERED INDEX [NonClusteredIX_tb_KostenKategorie] ON [dbo].[tb_KostenKategorie]
(
	[KostenKategorieID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIX_tb_Verwand]    Script Date: 28.10.2022 11:14:25 ******/
CREATE UNIQUE NONCLUSTERED INDEX [NonClusteredIX_tb_Verwand] ON [dbo].[tb_Verwand]
(
	[VerwandID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tb_Ausgaben]  WITH CHECK ADD  CONSTRAINT [FK_tb_Ausgaben_tb_KostenArt] FOREIGN KEY([KostenArtID])
REFERENCES [dbo].[tb_KostenArt] ([KostenArtID])
GO
ALTER TABLE [dbo].[tb_Ausgaben] CHECK CONSTRAINT [FK_tb_Ausgaben_tb_KostenArt]
GO
ALTER TABLE [dbo].[tb_Ausgaben]  WITH CHECK ADD  CONSTRAINT [FK_tb_Ausgaben_tb_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[tb_Person] ([PersonID])
GO
ALTER TABLE [dbo].[tb_Ausgaben] CHECK CONSTRAINT [FK_tb_Ausgaben_tb_Person]
GO
ALTER TABLE [dbo].[tb_Eingaben]  WITH CHECK ADD  CONSTRAINT [FK_tb_Eingaben_tb_GehaltArt] FOREIGN KEY([GehaltArtID])
REFERENCES [dbo].[tb_GehaltArt] ([GehaltArtID])
GO
ALTER TABLE [dbo].[tb_Eingaben] CHECK CONSTRAINT [FK_tb_Eingaben_tb_GehaltArt]
GO
ALTER TABLE [dbo].[tb_Eingaben]  WITH CHECK ADD  CONSTRAINT [FK_tb_Eingaben_tb_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[tb_Person] ([PersonID])
GO
ALTER TABLE [dbo].[tb_Eingaben] CHECK CONSTRAINT [FK_tb_Eingaben_tb_Person]
GO
ALTER TABLE [dbo].[tb_GehaltArt]  WITH CHECK ADD  CONSTRAINT [FK_tb_GehaltArt_tb_GehaltKategorie] FOREIGN KEY([GehaltKategorieID])
REFERENCES [dbo].[tb_GehaltKategorie] ([GehaltKategorieID])
GO
ALTER TABLE [dbo].[tb_GehaltArt] CHECK CONSTRAINT [FK_tb_GehaltArt_tb_GehaltKategorie]
GO
ALTER TABLE [dbo].[tb_KostenArt]  WITH CHECK ADD  CONSTRAINT [FK_tb_KostenArt_tb_KostenKategorie] FOREIGN KEY([KostenKategorieID])
REFERENCES [dbo].[tb_KostenKategorie] ([KostenKategorieID])
GO
ALTER TABLE [dbo].[tb_KostenArt] CHECK CONSTRAINT [FK_tb_KostenArt_tb_KostenKategorie]
GO
ALTER TABLE [dbo].[tb_Person]  WITH CHECK ADD  CONSTRAINT [FK_tb_Person_tb_Familie] FOREIGN KEY([FamilieID])
REFERENCES [dbo].[tb_Familie] ([FamilieID])
GO
ALTER TABLE [dbo].[tb_Person] CHECK CONSTRAINT [FK_tb_Person_tb_Familie]
GO
ALTER TABLE [dbo].[tb_Person]  WITH CHECK ADD  CONSTRAINT [FK_tb_Person_tb_Geschlecth] FOREIGN KEY([GeschlechtID])
REFERENCES [dbo].[tb_Geschlecth] ([GeschlecthID])
GO
ALTER TABLE [dbo].[tb_Person] CHECK CONSTRAINT [FK_tb_Person_tb_Geschlecth]
GO
ALTER TABLE [dbo].[tb_Person]  WITH CHECK ADD  CONSTRAINT [FK_tb_Person_tb_Verwand] FOREIGN KEY([VerwandID])
REFERENCES [dbo].[tb_Verwand] ([VerwandID])
GO
ALTER TABLE [dbo].[tb_Person] CHECK CONSTRAINT [FK_tb_Person_tb_Verwand]
GO
ALTER TABLE [dbo].[tb_Ausgaben]  WITH CHECK ADD  CONSTRAINT [CK_tb_Ausgaben_Datum] CHECK  (([Datum]<=getdate()))
GO
ALTER TABLE [dbo].[tb_Ausgaben] CHECK CONSTRAINT [CK_tb_Ausgaben_Datum]
GO
ALTER TABLE [dbo].[tb_Ausgaben]  WITH CHECK ADD  CONSTRAINT [CK_tb_Ausgaben_SUME] CHECK  (([Sume]>(0)))
GO
ALTER TABLE [dbo].[tb_Ausgaben] CHECK CONSTRAINT [CK_tb_Ausgaben_SUME]
GO
ALTER TABLE [dbo].[tb_Eingaben]  WITH CHECK ADD  CONSTRAINT [CK_Eingaben_Datum] CHECK  (([Datum]<=getdate()))
GO
ALTER TABLE [dbo].[tb_Eingaben] CHECK CONSTRAINT [CK_Eingaben_Datum]
GO
/****** Object:  StoredProcedure [dbo].[sp_AddAusgabe]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <26.101.2022>
-- Description:	<Procedure für Insert in Ausgabe tablle>
-- =============================================
CREATE     PROCEDURE [dbo].[sp_AddAusgabe] 
	@Datum DATE,
	@KostenArtID int,
	@PersonID int,
	@Sum money,
	@Kommentar text,
	-----
	@Erfolg bit OUTPUT, -- geklappt oder nicht
	@Feedback VARCHAR(MAX) OUTPUT -- Fehlermeldungen etc.
AS
BEGIN	
	-- Hilfsvariablen deklarieren	
	DECLARE @CheckResult AS int,
			@Name nvarchar(30),
			@Kostenart nvarchar(30),
			@Kostenartkategorie nvarchar(30),
			@PerGrenze float,
			@ActaulPer float,
			@msg AS varchar(MAX);
	-------------------------------	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET @Erfolg = 1;
	SET @Feedback = 'Alles OK!';	
	BEGIN TRY
		-----1.Test erste bedingung, ist 18 Jahre und ist kostenart erlaubt-----

		-- Person name erhalten---
		SELECT @Name = Name FROM dbo.tb_Person WHERE @PersonID = PersonID;

		---Kostenart erhalten---
		SELECT @Kostenart = KostenArt FROM dbo.tb_KostenArt WHERE @KostenArtID = KostenArtID;

		IF (dbo.sf_GetAge(@PersonID) <18)
		BEGIN
			IF (dbo.sf_istKostenarterlaubtab18(@KostenArtID) = 1)
			BEGIN
				SET @msg = @Name + ' ist jünger als 18 Jahre und darf keinen '+ @Kostenart + ' hinzufügen.';
				THROW 50102, @msg, 1;
			END
		END
		
		-- 2.Test zweite bedingung ,percentage ausgaben for kostenart kategorie----
		----test day value >15, Kostenkategorie sparen has no grenze--
		IF (DAY(@Datum)<15)
		BEGIN 
			INSERT INTO [dbo].[tb_Ausgaben]
				   (Datum, KostenArtID, PersonID, Sume, Kommentar)
			VALUES (@Datum, @KostenArtID, @PersonID, @Sum, @Kommentar);
			SET @Feedback = '1 Datensatz hinzugefügt';
		END
		ELSE 
		BEGIN
			---Kostenart categorie erhalten----
			SELECT @Kostenartkategorie=KostenKategorie FROM dbo.tb_KostenKategorie INNER JOIN 
			dbo.tb_KostenArt ON dbo.tb_KostenKategorie.KostenKategorieID = dbo.tb_KostenArt.KostenKategorieID
			WHERE @KostenArtID = KostenArtID;

			IF (@Kostenartkategorie = 'Sparen')
			BEGIN 
			INSERT INTO [dbo].[tb_Ausgaben]
				   (Datum, KostenArtID, PersonID, Sume, Kommentar)
			VALUES (@Datum, @KostenArtID, @PersonID, @Sum, @Kommentar);
			SET @Feedback = '1 Datensatz hinzugefügt';
			END
			ELSE
				BEGIN
				---Percentage grenze erhalten---
				SELECT @PerGrenze = PercentageGrenze FROM dbo.tb_KostenKategorie 
				WHERE @Kostenartkategorie = KostenKategorie;

				SET @ActaulPer = dbo.sf_GetPercentageKategorie(@PersonID, @KostenArtID, @Datum);

					IF (@ActaulPer > @PerGrenze)
					BEGIN
						SET @msg = @Name + ' hat ' + Convert(nvarchar(5), @ActaulPer) + 
						' für ' + @Kostenartkategorie + ' ausgegeben. Das ist über ' + Convert(nvarchar(5), @PerGrenze) + ' Grenze ';
						THROW 50103, @msg, 1;
					END
					ELSE
					BEGIN 
					INSERT INTO [dbo].[tb_Ausgaben]
								(Datum, KostenArtID, PersonID, Sume, Kommentar)
					VALUES (@Datum, @KostenArtID, @PersonID, @Sum, @Kommentar);
					SET @Feedback = '1 Datensatz hinzugefügt';
					END
			END

		END
		
	END TRY 

	BEGIN CATCH
		SET @Erfolg = 0; -- nicht geklappt--
		-- 	@Feedback text OUTPUT --Fehlermeldungen etc.
		SET @Feedback = 
			ERROR_MESSAGE() + ' Fehler Nr. '+ CONVERT(varchar, ERROR_NUMBER())
						+ ' Prozedur: '  + ERROR_PROCEDURE()
						+ ' Zeile Nr.: ' + CONVERT(varchar,  ERROR_LINE());
	END CATCH; 
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Backup_mit_Zeitstempel_und_Param_OutputUndFehlermeldung]    Script Date: 28.10.2022 11:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [dbo].[sp_Backup_mit_Zeitstempel_und_Param_OutputUndFehlermeldung]
	@Pfad nvarchar(MAX),	-- Parameter 1,--@Pfad soll so aussehen: 'C:\SQL-Kurs\DB\Firma\Backup\' 
	@Feedback nvarchar(MAX) OUTPUT -- Parameter 2
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    BEGIN TRY
		DECLARE @backupFile NVARCHAR(MAX); -- file name
		SET @backupFile = @Pfad + 
						  'HomeDBD2-' + [dbo].[sf_Zeitstempel]() + '.bak';
   
		BACKUP DATABASE [HomeDBD2] TO DISK = @backupFile;
		SET @Feedback = CHAR(10) + 'Alles OK!';
	END TRY
	BEGIN CATCH	
	
		SET @Feedback = ERROR_MESSAGE() + CHAR(10)-- Zeilenumbruch
						+ 'Fehler Nr. ' + CONVERT(varchar, ERROR_NUMBER()) + CHAR(10)
						+ 'Prozedur: '  + ERROR_PROCEDURE() + CHAR(10)
						+ 'Zeile Nr.: ' + CONVERT(varchar,  ERROR_LINE());	

	END CATCH
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[31] 4[23] 2[15] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_Person"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_Ausgaben"
            Begin Extent = 
               Top = 10
               Left = 353
               Bottom = 140
               Right = 520
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "tb_KostenArt"
            Begin Extent = 
               Top = 6
               Left = 597
               Bottom = 119
               Right = 783
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_KostenKategorie"
            Begin Extent = 
               Top = 13
               Left = 885
               Bottom = 109
               Right = 1071
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2985
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Ausgabe_per_KategoriePerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Ausgabe_per_KategoriePerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Ausgabe_per_KategoriePerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[37] 4[19] 2[13] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_Person"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_Ausgaben"
            Begin Extent = 
               Top = 6
               Left = 243
               Bottom = 161
               Right = 410
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_KostenArt"
            Begin Extent = 
               Top = 6
               Left = 448
               Bottom = 119
               Right = 634
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_KostenKategorie"
            Begin Extent = 
               Top = 6
               Left = 672
               Bottom = 102
               Right = 858
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Ausgabe_per_MonthPerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Ausgabe_per_MonthPerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Ausgabe_per_MonthPerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_Person"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_Eingaben"
            Begin Extent = 
               Top = 6
               Left = 243
               Bottom = 171
               Right = 410
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_GehaltArt"
            Begin Extent = 
               Top = 6
               Left = 448
               Bottom = 147
               Right = 632
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_GehaltKategorie"
            Begin Extent = 
               Top = 6
               Left = 670
               Bottom = 122
               Right = 854
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Eingabe_per_KategoriePerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Eingabe_per_KategoriePerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Eingabe_per_KategoriePerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_Person"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "tb_Eingaben"
            Begin Extent = 
               Top = 6
               Left = 243
               Bottom = 174
               Right = 410
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_GehaltArt"
            Begin Extent = 
               Top = 6
               Left = 448
               Bottom = 160
               Right = 632
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_GehaltKategorie"
            Begin Extent = 
               Top = 6
               Left = 670
               Bottom = 102
               Right = 854
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Eingabe_per_MonthPerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Eingabe_per_MonthPerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_Eingabe_per_MonthPerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tb_Person"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_KostenArt"
            Begin Extent = 
               Top = 23
               Left = 561
               Bottom = 153
               Right = 747
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_KostenKategorie"
            Begin Extent = 
               Top = 59
               Left = 805
               Bottom = 172
               Right = 991
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tb_Ausgaben"
            Begin Extent = 
               Top = 17
               Left = 306
               Bottom = 147
               Right = 473
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_KostenArtCount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_KostenArtCount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_KostenArtCount'
GO
USE [master]
GO
ALTER DATABASE [HomeDBD2] SET  READ_WRITE 
GO
