USE [master]
GO
/****** Object:  Database [chaos]    Script Date: 13/10/2023 16:41:03 ******/
CREATE DATABASE [chaos]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'chaos', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\chaos.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'chaos_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\chaos_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [chaos] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [chaos].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [chaos] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [chaos] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [chaos] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [chaos] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [chaos] SET ARITHABORT OFF 
GO
ALTER DATABASE [chaos] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [chaos] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [chaos] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [chaos] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [chaos] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [chaos] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [chaos] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [chaos] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [chaos] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [chaos] SET  DISABLE_BROKER 
GO
ALTER DATABASE [chaos] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [chaos] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [chaos] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [chaos] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [chaos] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [chaos] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [chaos] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [chaos] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [chaos] SET  MULTI_USER 
GO
ALTER DATABASE [chaos] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [chaos] SET DB_CHAINING OFF 
GO
ALTER DATABASE [chaos] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [chaos] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [chaos] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [chaos] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [chaos] SET QUERY_STORE = OFF
GO
USE [chaos]
GO
/****** Object:  Table [dbo].[instrument]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[instrument](
	[instrument_id] [bigint] IDENTITY(1,1) NOT NULL,
	[symbol] [varchar](2000) NOT NULL,
	[base] [varchar](200) NOT NULL,
	[underlying] [varchar](200) NOT NULL,
	[instrument_type] [int] NOT NULL,
	[instrument_sub_type] [int] NOT NULL,
	[description] [varchar](400) NOT NULL,
	[primary_exchange_id] [int] NOT NULL,
	[currency] [varchar](8) NOT NULL,
	[point_value] [float] NOT NULL,
	[tick_size] [float] NOT NULL,
	[tick_size_type] [int] NOT NULL,
	[gics_sector] [varchar](200) NOT NULL,
	[gics_sub_industry] [varchar](200) NOT NULL,
	[first_trade_date] [date] NOT NULL,
	[first_notice_date] [date] NOT NULL,
	[roll_date] [date] NOT NULL,
	[expiry_date] [date] NOT NULL,
	[expiry_time] [time](7) NOT NULL,
	[expiry_type] [int] NOT NULL,
	[settlement_type] [int] NOT NULL,
	[market_open_time] [time](7) NOT NULL,
	[market_close_time] [time](7) NOT NULL,
	[market_time_tz] [varchar](40) NULL,
	[region_id] [int] NOT NULL,
	[calendar_code] [varchar](40) NULL,
	[is_active] [int] NOT NULL,
 CONSTRAINT [PK_instrument] PRIMARY KEY CLUSTERED 
(
	[instrument_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[view_kraken_symbols]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_kraken_symbols]
AS
SELECT        instrument_id, base, underlying AS kraken_ticker
FROM            dbo.instrument
WHERE        (is_active = 1) AND (instrument_type = 4)
GO
/****** Object:  Table [dbo].[yahoo_ohlc]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[yahoo_ohlc](
	[instrument_id] [bigint] NOT NULL,
	[trade_date] [date] NOT NULL,
	[open_price] [float] NULL,
	[high_price] [float] NULL,
	[low_price] [float] NULL,
	[close_price] [float] NULL,
	[volume] [int] NULL,
	[adjusted_close] [float] NULL,
 CONSTRAINT [PK_yahoo_ohlc] PRIMARY KEY CLUSTERED 
(
	[instrument_id] ASC,
	[trade_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[view_python_excel_friendly_market_data]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_python_excel_friendly_market_data]
AS
SELECT        dbo.yahoo_ohlc.trade_date, dbo.instrument.base, dbo.yahoo_ohlc.adjusted_close, dbo.instrument.gics_sector, dbo.instrument.gics_sub_industry
FROM            dbo.instrument INNER JOIN
                         dbo.yahoo_ohlc ON dbo.instrument.instrument_id = dbo.yahoo_ohlc.instrument_id
WHERE        (dbo.instrument.is_active = 1)
GO
/****** Object:  Table [dbo].[realtime_testing_pairs]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[realtime_testing_pairs](
	[symbol] [varchar](40) NOT NULL,
 CONSTRAINT [PK_realtime_testing_pairs] PRIMARY KEY CLUSTERED 
(
	[symbol] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[view_python_excel_friendly_trading_pairs_market_data]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_python_excel_friendly_trading_pairs_market_data]
AS
SELECT        dbo.yahoo_ohlc.trade_date, dbo.realtime_testing_pairs.symbol, dbo.yahoo_ohlc.adjusted_close
FROM            dbo.instrument INNER JOIN
                         dbo.realtime_testing_pairs ON dbo.instrument.base = dbo.realtime_testing_pairs.symbol INNER JOIN
                         dbo.yahoo_ohlc ON dbo.instrument.instrument_id = dbo.yahoo_ohlc.instrument_id
GO
/****** Object:  View [dbo].[view_yahoo_symbols]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_yahoo_symbols]
AS
SELECT        instrument_id, base
FROM            dbo.instrument
WHERE        (instrument_type = 1) AND (primary_exchange_id = 1) AND (is_active = 1)
GO
/****** Object:  View [dbo].[view_gics_sector]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_gics_sector]
AS
SELECT DISTINCT gics_sector
FROM            dbo.instrument
GO
/****** Object:  View [dbo].[view_gics_sub_industry]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_gics_sub_industry]
AS
SELECT DISTINCT gics_sub_industry
FROM            dbo.instrument
GO
/****** Object:  View [dbo].[view_instrument_by_sector]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_instrument_by_sector]
AS
SELECT        instrument_id, base, gics_sector, gics_sub_industry
FROM            dbo.instrument
GO
/****** Object:  View [dbo].[view_yahoo_ohlc_by_sector]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_yahoo_ohlc_by_sector]
AS
SELECT        dbo.yahoo_ohlc.trade_date, dbo.instrument.base, dbo.yahoo_ohlc.adjusted_close
FROM            dbo.instrument INNER JOIN
                         dbo.yahoo_ohlc ON dbo.instrument.instrument_id = dbo.yahoo_ohlc.instrument_id
GO
/****** Object:  Table [dbo].[exchange_id]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[exchange_id](
	[id] [int] NULL,
	[exchange] [varchar](200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[expiry_type]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[expiry_type](
	[type] [int] NOT NULL,
	[description] [varchar](200) NULL,
 CONSTRAINT [PK_expiry_type] PRIMARY KEY CLUSTERED 
(
	[type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[instrument_option_detail]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[instrument_option_detail](
	[instrument_id] [int] NOT NULL,
	[strike] [float] NOT NULL,
	[version] [int] NOT NULL,
 CONSTRAINT [PK_instrument_option_detail] PRIMARY KEY CLUSTERED 
(
	[instrument_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[instrument_sub_type]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[instrument_sub_type](
	[type] [int] NOT NULL,
	[description] [varchar](200) NULL,
 CONSTRAINT [PK_instrument_sub_type] PRIMARY KEY CLUSTERED 
(
	[type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[instrument_type]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[instrument_type](
	[type] [int] NOT NULL,
	[description] [varchar](200) NULL,
 CONSTRAINT [PK_instrument_type] PRIMARY KEY CLUSTERED 
(
	[type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[realtime_testing_option_data]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[realtime_testing_option_data](
	[trade_date] [date] NOT NULL,
	[base] [varchar](40) NOT NULL,
	[option_expiration] [date] NULL,
	[call_price] [float] NULL,
	[call_strike] [float] NULL,
	[put_strike] [float] NULL,
	[put_price] [float] NULL,
 CONSTRAINT [PK_realtime_testing_option_data] PRIMARY KEY CLUSTERED 
(
	[trade_date] ASC,
	[base] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[regon_id]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[regon_id](
	[id] [int] NOT NULL,
	[region] [varchar](200) NULL,
 CONSTRAINT [PK_regon_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[settlement_type]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[settlement_type](
	[type] [int] NOT NULL,
	[description] [varchar](120) NULL,
 CONSTRAINT [PK_settlement_type] PRIMARY KEY CLUSTERED 
(
	[type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tick_size_type]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tick_size_type](
	[type] [int] NOT NULL,
	[descripton] [varchar](200) NULL,
 CONSTRAINT [PK_tick_size_type] PRIMARY KEY CLUSTERED 
(
	[type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_instrument]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_insert_instrument]
	-- Add the parameters for the stored procedure here
	@in_symbol varchar(2000),
    @in_base varchar(200),
    @in_underlying varchar(200),
    @in_instrument_type int,
    @in_instrument_sub_type int,
    @in_description varchar(400),
    @in_primary_exchange int,
    @in_currency varchar(8),
    @in_point_value float,
    @in_tick_size float,
    @in_tick_size_type int,
    @in_gics_sector varchar(200),
    @in_gics_sub_industry varchar(200),
    @in_first_trade_date date,
    @in_first_notice_date date,
    @in_roll_date date,
    @in_expiry_date date,
    @in_expiry_time time,
    @in_expiry_type int,
    @in_settlement_type int,
    @in_market_open_time time,
    @in_market_close_time time,
    @in_market_time_tz varchar(40),
    @in_region_id int,
    @in_calendar_code varchar(40),
    @in_is_active int
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
		BEGIN TRANSACTION

		INSERT INTO [dbo].instrument( symbol, base, underlying, instrument_type, instrument_sub_type, description, primary_exchange_id, currency, point_value, tick_size, tick_size_type, gics_sector,
										gics_sub_industry, first_trade_date, first_notice_date, roll_date, expiry_date, expiry_time, expiry_type, settlement_type, market_open_time, market_close_time,
										market_time_tz, region_id, calendar_code, is_active )
		VALUES( @in_symbol,
				@in_base,
				@in_underlying,
				@in_instrument_type,
				@in_instrument_sub_type,
				@in_description,
				@in_primary_exchange,
				@in_currency,
				@in_point_value,
				@in_tick_size,
				@in_tick_size_type,
				@in_gics_sector,
				@in_gics_sub_industry,
				@in_first_trade_date,
				@in_first_notice_date,
				@in_roll_date,
				@in_expiry_date,
				@in_expiry_time,
				@in_expiry_type,
				@in_settlement_type,
				@in_market_open_time,
				@in_market_close_time,
				@in_market_time_tz,
				@in_region_id,
				@in_calendar_code,
				@in_is_active )

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @err_severity int,
				@err_number int,
				@err_msg varchar(2000),
				@err_state int,
				@err_line int,
				@err_proc varchar(120),
				@error_message varchar(120)

		SET @err_severity = ERROR_SEVERITY()
		SET @err_number = ERROR_NUMBER()
		SET @err_msg = ERROR_MESSAGE()
		SET @err_state = ERROR_STATE()
		SET @err_line = ERROR_LINE()
		SET @err_proc = ERROR_PROCEDURE()
		SET @error_message = 'Problem executing stored procedure. MSSQL Server error number: ' + CAST(@err_number as varchar(12)) + ' in sp: ' + @err_proc + ' line: '
			+ CAST(@err_line as varchar(12)) + ' msg: ' + @err_msg

		IF @err_state = 0
			SET @err_state = 1

		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END
		RAISERROR( @error_message, @err_severity, @err_state, @err_number )
 
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[sp_upsert_yahoo_ohlc]    Script Date: 13/10/2023 16:41:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_upsert_yahoo_ohlc]
	-- Add the parameters for the stored procedure here
	@in_trade_date date,
	@in_id bigint,
	@in_open float,
	@in_high float,
	@in_low float,
	@in_close float,
	@in_adj float,
	@in_vol int
AS
BEGIN
	-- Example on how to upsert
	-- https://michaeljswart.com/2017/07/sql-server-upsert-patterns-and-antipatterns/

	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
		BEGIN TRANSACTION

		IF EXISTS ( SELECT * FROM [dbo].yahoo_ohlc WITH (UPDLOCK) WHERE (instrument_id = @in_id) AND (trade_date = @in_trade_date) )
			-- The record already exists so update it
			UPDATE [dbo].yahoo_ohlc
			SET open_price = @in_open, high_price = @in_high, low_price = @in_low, close_price = @in_close, adjusted_close = @in_adj, volume = @in_vol
			WHERE (instrument_id = @in_id) AND (trade_date = @in_trade_date)
 
		ELSE
			-- It doesn't exist so add it
			INSERT INTO [dbo].yahoo_ohlc( trade_date, instrument_id, open_price, high_price, low_price, close_price, adjusted_close, volume )
			VALUES( @in_trade_date, @in_id, @in_open, @in_high, @in_low, @in_close, @in_adj, @in_vol )

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @err_severity int,
				@err_number int,
				@err_msg varchar(2000),
				@err_state int,
				@err_line int,
				@err_proc varchar(120),
				@error_message varchar(120)

		SET @err_severity = ERROR_SEVERITY()
		SET @err_number = ERROR_NUMBER()
		SET @err_msg = ERROR_MESSAGE()
		SET @err_state = ERROR_STATE()
		SET @err_line = ERROR_LINE()
		SET @err_proc = ERROR_PROCEDURE()
		SET @error_message = 'Problem executing stored procedure. MSSQL Server error number: ' + CAST(@err_number as varchar(12)) + ' in sp: ' + @err_proc + ' line: '
			+ CAST(@err_line as varchar(12)) + ' msg: ' + @err_msg

		IF @err_state = 0
			SET @err_state = 1

		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END
		RAISERROR( @error_message, @err_severity, @err_state, @err_number )
 
	END CATCH

END
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
         Begin Table = "instrument"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 301
               Right = 293
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
         Width = 2580
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
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_gics_sector'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_gics_sector'
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
         Begin Table = "instrument"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 290
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 1
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
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_gics_sub_industry'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_gics_sub_industry'
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
         Begin Table = "instrument"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 304
               Right = 345
            End
            DisplayFlags = 280
            TopColumn = 1
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
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_instrument_by_sector'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_instrument_by_sector'
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
         Begin Table = "instrument"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 313
               Right = 260
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
         Alias = 1590
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
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_kraken_symbols'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_kraken_symbols'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[42] 4[24] 2[8] 3) )"
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
         Begin Table = "instrument"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 303
               Right = 252
            End
            DisplayFlags = 280
            TopColumn = 14
         End
         Begin Table = "yahoo_ohlc"
            Begin Extent = 
               Top = 6
               Left = 277
               Bottom = 237
               Right = 460
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
         Width = 2745
         Width = 3420
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
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_python_excel_friendly_market_data'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_python_excel_friendly_market_data'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[12] 3) )"
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
         Begin Table = "instrument"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "realtime_testing_pairs"
            Begin Extent = 
               Top = 196
               Left = 304
               Bottom = 275
               Right = 474
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "yahoo_ohlc"
            Begin Extent = 
               Top = 17
               Left = 305
               Bottom = 179
               Right = 475
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
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_python_excel_friendly_trading_pairs_market_data'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_python_excel_friendly_trading_pairs_market_data'
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
         Begin Table = "instrument"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 303
               Right = 252
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "yahoo_ohlc"
            Begin Extent = 
               Top = 6
               Left = 277
               Bottom = 237
               Right = 460
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
         Width = 3270
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
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_yahoo_ohlc_by_sector'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_yahoo_ohlc_by_sector'
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
         Begin Table = "instrument"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 268
               Right = 287
            End
            DisplayFlags = 280
            TopColumn = 16
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
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_yahoo_symbols'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_yahoo_symbols'
GO
USE [master]
GO
ALTER DATABASE [chaos] SET  READ_WRITE 
GO
