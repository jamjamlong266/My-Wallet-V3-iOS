//
//  ExchangeDetailView.m
//  Blockchain
//
//  Created by Maurice A. on 11/20/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ExchangeDetailView.h"
#import "ExchangeTrade.h"
#import "BCLine.h"
#import "UIView+ChangeFrameAttribute.h"
#import "NSDateFormatter+VerboseString.h"

#define MARGIN_HORIZONTAL 20
#define NUMBER_OF_ROWS_FETCHED_TRADE 6
#define NUMBER_OF_ROWS_BUILT_TRADE 6

@implementation ExchangeDetailView

- (instancetype)initWithFrame:(CGRect)frame fetchedTrade:(ExchangeTrade *)trade
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self changeHeight:NUMBER_OF_ROWS_FETCHED_TRADE * [ExchangeDetailView rowHeight]];
        [self setupPseudoTableWithFetchedTrade:trade];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame builtTrade:(ExchangeTrade *)trade
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self changeHeight:NUMBER_OF_ROWS_BUILT_TRADE * [ExchangeDetailView rowHeight]];
        [self setupPseudoTableWithBuiltTrade:trade];
    }
    return self;
}

- (void)setupPseudoTableWithFetchedTrade:(ExchangeTrade *)trade
{
    // Rendering Logic
    NSString *depositCurrencySymbol = [[trade depositCurrency] uppercaseString];
    NSString *withdrawalCurrencySymbol = [[trade withdrawalCurrency] uppercaseString];
    NSString *depositCurrency = [depositCurrencySymbol isEqual: CURRENCY_SYMBOL_BTC] ? BC_STRING_BITCOIN : BC_STRING_ETHER;
    NSString *receiveCurrency = [depositCurrencySymbol isEqual:CURRENCY_SYMBOL_BTC] ? BC_STRING_ETHER : BC_STRING_BITCOIN;
    NSString *depositAmount = [NSString stringWithFormat:@"%@ %@", trade.depositAmount, depositCurrencySymbol];
    NSString *withdrawAmount = [NSString stringWithFormat:@"%@ %@", trade.withdrawalAmount, withdrawalCurrencySymbol];
    NSString *minerFee = [NSString stringWithFormat:@"%@ %@", trade.minerFee, depositCurrencySymbol];

    UIView *rowDeposit = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_ARGUMENT_TO_DEPOSIT, depositCurrency] accessoryText:depositAmount yPosition:0];
    [self addSubview:rowDeposit];

    UIView *rowReceive = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_ARGUMENT_TO_BE_RECEIVED, receiveCurrency] accessoryText:withdrawAmount yPosition:rowDeposit.frame.origin.y + rowDeposit.frame.size.height];
    [self addSubview:rowReceive];

    UIView *rowExchangeRate = [self rowViewWithText:BC_STRING_EXCHANGE_RATE accessoryText:trade.exchangeRateString yPosition:rowReceive.frame.origin.y + rowReceive.frame.size.height];
    [self addSubview:rowExchangeRate];

    UIView *rowTransactionFee = [self rowViewWithText:BC_STRING_TRANSACTION_FEE accessoryText:minerFee yPosition:rowExchangeRate.frame.origin.y + rowExchangeRate.frame.size.height];
    [self addSubview:rowTransactionFee];

    UIView *rowOrderID = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_EXCHANGE_ORDER_ID, @""] accessoryText:trade.orderID yPosition:rowTransactionFee.frame.origin.y + rowTransactionFee.frame.size.height];
    [self addSubview:rowOrderID];
    
    UIView *rowDate = [self rowViewWithText:BC_STRING_DATE accessoryText:[NSDateFormatter verboseStringFromDate:trade.date] yPosition:rowOrderID.frame.origin.y + rowOrderID.frame.size.height];
    [self addSubview:rowDate];

    BCLine *bottomLine = [[BCLine alloc] initWithYPosition:rowDate.frame.origin.y + rowDate.frame.size.height];
    [self addSubview:bottomLine];
}

- (void)setupPseudoTableWithBuiltTrade:(ExchangeTrade *)trade
{
    // Rendering Logic
    NSString *depositCurrencySymbol = [[trade depositCurrency] uppercaseString];
    NSString *withdrawalCurrencySymbol = [[trade withdrawalCurrency] uppercaseString];
    NSString *depositCurrency = [depositCurrencySymbol isEqual: CURRENCY_SYMBOL_BTC] ? BC_STRING_BITCOIN : BC_STRING_ETHER;
    NSString *receiveCurrency = [depositCurrencySymbol isEqual:CURRENCY_SYMBOL_BTC] ? BC_STRING_ETHER : BC_STRING_BITCOIN;
    NSString *depositAmount = [NSString stringWithFormat:@"%@ %@", trade.depositAmount, depositCurrencySymbol];
    NSString *withdrawAmount = [NSString stringWithFormat:@"%@ %@", trade.withdrawalAmount, withdrawalCurrencySymbol];
    NSString *transactionFee = [NSString stringWithFormat:@"%@ %@", trade.transactionFee, depositCurrencySymbol];
    NSString *minerFee = [NSString stringWithFormat:@"%@ %@", trade.minerFee, depositCurrencySymbol];
    NSString *totalSpent = [NSString stringWithFormat:@"%@ %@", [[[trade.depositAmount decimalNumberByAdding:trade.transactionFee] decimalNumberByAdding:trade.minerFee] stringValue], depositCurrencySymbol];
    
    UIView *rowDeposit = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_ARGUMENT_TO_DEPOSIT, depositCurrency] accessoryText:depositAmount yPosition:0];
    [self addSubview:rowDeposit];

    UIView *rowTransactionFee = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_TRANSACTION_FEE, depositCurrency] accessoryText:transactionFee yPosition:rowDeposit.frame.origin.y + rowDeposit.frame.size.height];
    [self addSubview:rowTransactionFee];
    
    UIView *rowTotalSpent = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_TOTAL_ARGUMENT_SPENT, depositCurrency] accessoryText:totalSpent yPosition:rowTransactionFee.frame.origin.y + rowTransactionFee.frame.size.height];
    [self addSubview:rowTotalSpent];
    
    UIView *rowExchangeRate = [self rowViewWithText:BC_STRING_EXCHANGE_RATE accessoryText:trade.exchangeRateString yPosition:rowTotalSpent.frame.origin.y + rowTotalSpent.frame.size.height];
    [self addSubview:rowExchangeRate];
    
    UIView *rowNetworkTransactionFee = [self rowViewWithText:BC_STRING_NETWORK_TRANSACTION_FEE accessoryText:minerFee yPosition:rowExchangeRate.frame.origin.y + rowExchangeRate.frame.size.height];
    [self addSubview:rowNetworkTransactionFee];
    
    UIView *rowReceive = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_ARGUMENT_TO_BE_RECEIVED, receiveCurrency] accessoryText:withdrawAmount yPosition:rowNetworkTransactionFee.frame.origin.y + rowNetworkTransactionFee.frame.size.height];
    [self addSubview:rowReceive];
    
    BCLine *bottomLine = [[BCLine alloc] initWithYPosition:rowReceive.frame.origin.y + rowReceive.frame.size.height];
    [self addSubview:bottomLine];
}

- (UIView *)rowViewWithText:(NSString *)text accessoryText:(NSString *)accessoryText yPosition:(CGFloat)posY
{
    CGFloat horizontalMargin = MARGIN_HORIZONTAL;
    CGFloat rowWidth = WINDOW_WIDTH;
    CGFloat rowHeight = [ExchangeDetailView rowHeight];
    UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, posY, rowWidth, rowHeight)];

    UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin, 0, rowWidth/2, rowHeight)];
    mainLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    mainLabel.textColor = COLOR_TEXT_DARK_GRAY;
    mainLabel.text = text;
    [rowView addSubview:mainLabel];

    UILabel *accessoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(rowWidth/2, 0, rowWidth/2 - horizontalMargin, rowHeight)];
    accessoryLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    accessoryLabel.text = accessoryText;
    accessoryLabel.textColor = COLOR_TEXT_DARK_GRAY;
    accessoryLabel.textAlignment = NSTextAlignmentRight;
    accessoryLabel.numberOfLines = 0;
    [rowView addSubview:accessoryLabel];

    BCLine *topLine = [[BCLine alloc] initWithYPosition:posY];
    [self addSubview:topLine];

    return rowView;
}

+ (CGFloat)rowHeight
{
    BOOL isUsingLargeScreenSize = IS_USING_SCREEN_SIZE_LARGER_THAN_5S;
    BOOL isUsing4S = IS_USING_SCREEN_SIZE_4S;
    CGFloat rowHeight = isUsingLargeScreenSize ? 60 : isUsing4S ? 44 : 50;
    return rowHeight;
}

@end