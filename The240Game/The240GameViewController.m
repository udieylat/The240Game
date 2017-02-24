//
//  The240GameViewController.m
//  The240Game
//
//  Created by Yuval on 8/12/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

#import <FacebookSDK/FacebookSDK.h>

#import "Flurry.h"
#import "iRate.h"
#import "GADBannerView.h"
#import "GADRequest.h"

#import "Board.h"
#import "GameInfo.h"
#import "GameStatistics.h"
#import "Solver.h"
#import "SinglesModeManager.h"
#import "GameManager.h"

#import "The240GameViewController.h"

@interface The240GameViewController ()

@property (strong, nonatomic) Board *board;
@property (strong, nonatomic) GameInfo *gameInfo;
@property (strong, nonatomic) GameStatistics *gameStatistics;
@property (strong, nonatomic) Solver *solver;
@property (strong, nonatomic) SinglesModeManager *singlesModeManager;
@property (strong, nonatomic) GameManager *gameManager;
@property (strong, nonatomic) IBOutlet UIView *boardView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) NSMutableArray *grid; // of UIView
@property (strong, nonatomic) NSMutableArray *labelsGrid; // of UILabel
@property (strong, nonatomic) NSMutableArray *gridLines; // of UIView
@property (strong, nonatomic) NSMutableArray *frames; // of UIView

@property (strong, nonatomic) UIView *curCell;
@property (nonatomic) BOOL moveSwipeAllowed;
@property (nonatomic) BOOL longPressUsed;
@property (nonatomic) BOOL helpTextIsOn;
@property (nonatomic) BOOL helpTextTapAllowed;
@property (nonatomic) BOOL menuIsOn;
@property (nonatomic) BOOL gameIsCompleted;

@property (weak, nonatomic) IBOutlet UILabel *scoreTitleLabel; // Left side of "/" - score
@property (weak, nonatomic) IBOutlet UILabel *slashTitleLabel; // Only the "/"
@property (weak, nonatomic) IBOutlet UILabel *maxScoreTitleLabel; // Right side of "/" - the max score
@property (weak, nonatomic) IBOutlet UILabel *bestScoreTextLabel; // "Best:"
@property (weak, nonatomic) IBOutlet UILabel *bestScoreLabel; // Lower right best score
@property (strong, nonatomic) UILabel *helpTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *helpTextBackButton;

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (strong, nonatomic) UILabel *homeNewLabel;

@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@property (weak, nonatomic) IBOutlet UILabel *gameOverLabel;
@property (weak, nonatomic) IBOutlet UILabel *bigLevelAdvanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *helpTextSkipButton;
@property (weak, nonatomic) IBOutlet UILabel *helpTextNextLabel;
@property (weak, nonatomic) IBOutlet UITextView *howToPlayTextView;

@property (strong, nonatomic) UIButton *menuSoundToggleButton;
@property (strong, nonatomic) UIButton *gridSizeTogglingButton;
@property (strong, nonatomic) UIButton *singlesModeNextButton;
@property (strong, nonatomic) UIButton *singlesModePrevButton;
@property (strong, nonatomic) UIButton *singlesModeLastButton;
@property (strong, nonatomic) UIButton *singlesModeFirstButton;
@property (strong, nonatomic) NSMutableArray *homeButtons; // of UIButton
@property (strong, nonatomic) NSMutableArray *menuButtons; // of UIButton
@property (strong, nonatomic) NSMutableArray *restartButtons; // of UIButton
@property (strong, nonatomic) NSMutableArray *gameCompletionButtons; // of UIButton

@property (nonatomic) SystemSoundID moveSound;
@property (nonatomic) SystemSoundID cantMoveSound;
@property (nonatomic) SystemSoundID levelAdvanceSound;
@property (nonatomic) SystemSoundID lostSound;
@property (nonatomic) SystemSoundID completedTheGameSound;
@property (nonatomic) SystemSoundID retrySound;
@property (nonatomic) SystemSoundID goBackOneLevelSound;
@property (nonatomic) SystemSoundID toggleGridSizeSound;
@property (nonatomic) SystemSoundID menuInSound;
@property (nonatomic) SystemSoundID movieSound;

@property (nonatomic) BOOL debug;
@property (strong, nonatomic) NSMutableString *debugMovesStream;
@property (strong, nonatomic) NSArray *helpTextArray; // of NSString*
@property (nonatomic) NSUInteger helpTextArrayIndex;

@property (nonatomic) BOOL movie;
@property (nonatomic) BOOL deleteInfoFileHack;
@property (nonatomic) BOOL recolorMode;

@end

@implementation The240GameViewController

- (BOOL)moveSwipeAllowed
{
    if (!_moveSwipeAllowed) _moveSwipeAllowed = NO;
    return _moveSwipeAllowed;
}

- (BOOL)longPressUsed
{
    if (!_longPressUsed) _longPressUsed = NO;
    return _longPressUsed;
}

- (BOOL)helpTextIsOn
{
    if (!_helpTextIsOn) _helpTextIsOn = NO;
    return _helpTextIsOn;
}

- (BOOL)helpTextTapAllowed
{
    if (!_helpTextTapAllowed) _helpTextTapAllowed = NO;
    return _helpTextTapAllowed;
}

- (BOOL)menuIsOn
{
    if (!_menuIsOn) _menuIsOn = NO;
    return _menuIsOn;
}

- (BOOL)gameIsCompleted
{
    if (!_gameIsCompleted) _gameIsCompleted = NO;
    return _gameIsCompleted;
}

- (BOOL)debug
{
    if (!_debug) _debug = NO;
    return _debug;
}

- (BOOL)movie
{
    if (!_movie) _movie = NO;
    return _movie;
}

- (BOOL)deleteInfoFileHack
{
    if (!_deleteInfoFileHack) _deleteInfoFileHack = NO;
    return _deleteInfoFileHack;
}

- (BOOL)recolorMode
{
    if (!_recolorMode) _recolorMode = NO;
    return _recolorMode;
}

- (NSMutableString *)debugMovesStream
{
    if (!_debugMovesStream) _debugMovesStream = [[NSMutableString alloc] initWithString:@""];
    return _debugMovesStream;
}

- (Board *)board
{
    if (!_board) _board = [[Board alloc] init];
    return _board;
}

- (GameInfo *)gameInfo
{
    if (!_gameInfo) _gameInfo = [[GameInfo alloc] init];
    return _gameInfo;
}

- (GameStatistics *)gameStatistics
{
    if (!_gameStatistics) _gameStatistics = [[GameStatistics alloc] init];
    return _gameStatistics;
}

- (Solver *)solver
{
    if (!_solver) _solver = [[Solver alloc] init];
    return _solver;
}

- (SinglesModeManager *)singlesModeManager
{
    if (!_singlesModeManager) _singlesModeManager = [[SinglesModeManager alloc] init];
    return _singlesModeManager;
}

- (GameManager *)gameManager
{
    if (!_gameManager) _gameManager = [[GameManager alloc] init];
    return _gameManager;
}

- (NSMutableArray *)grid
{
    if (!_grid) _grid = [[NSMutableArray alloc] init];
    return _grid;
}

- (NSMutableArray *)labelsGrid
{
    if (!_labelsGrid) _labelsGrid = [[NSMutableArray alloc] init];
    return _labelsGrid;
}

- (NSMutableArray *)gridLines
{
    if (!_gridLines) _gridLines = [[NSMutableArray alloc] init];
    return _gridLines;
}

- (NSMutableArray *)frames
{
    if (!_frames) _frames = [[NSMutableArray alloc] init];
    return _frames;
}

- (NSMutableArray *)menuButtons
{
    if (!_menuButtons) _menuButtons = [[NSMutableArray alloc] init];
    return _menuButtons;
}

- (NSMutableArray *)homeButtons
{
    if (!_homeButtons) _homeButtons = [[NSMutableArray alloc] init];
    return _homeButtons;
}

- (NSMutableArray *)restartButtons
{
    if (!_restartButtons) _restartButtons = [[NSMutableArray alloc] init];
    return _restartButtons;
}

- (NSMutableArray *)gameCompletionButtons
{
    if (!_gameCompletionButtons) _gameCompletionButtons = [[NSMutableArray alloc] init];
    return _gameCompletionButtons;
}

- (UIView *)curCell
{
    if (!_curCell) _curCell = [[UIView alloc] init];
    return _curCell;
}

- (UILabel *)helpTextLabel
{
    if (!_helpTextLabel) _helpTextLabel = [[UILabel alloc] init];
    return _helpTextLabel;
}

- (UILabel *)homeNewLabel
{
    if (!_homeNewLabel) _homeNewLabel = [[UILabel alloc] init];
    return _homeNewLabel;
}

- (NSArray *)helpTextArray
{
    if (!_helpTextArray) _helpTextArray = [[NSArray alloc] init];
    return _helpTextArray;
}

- (NSUInteger)helpTextArrayIndex
{
    if (!_helpTextArrayIndex) _helpTextArrayIndex = 0;
    return _helpTextArrayIndex;
}

@synthesize bannerView;

#define STARTING_NUM_COLS 4
#define STARTING_NUM_ROWS 4

#pragma mark Init

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.moveSwipeAllowed = NO;
    self.helpTextTapAllowed = YES; // Only when help text is on, of course
    
    self.gameIsCompleted = NO;
    
    // One time init
    
    // Set to YES for tests, NO for release
    self.deleteInfoFileHack = NO;
    
    [self setSounds];
    [self addBoardFrame];
    [self updateHelpTextLabel];
    [self.boardView addSubview:self.curCell];
    
    [self setFontsAndButtons];
    [self setHowToPlayText];
    [self initHomeButtons];
    
    [[iRate sharedInstance] setAppStoreID:916255619];
    
    bannerView.delegate = self;

//    self.gadBannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716"; // test ad unit ID
    self.gadBannerView.adUnitID = @"ca-app-pub-7332132905347630/7249092306"; // the app's real ad unit ID
    self.gadBannerView.rootViewController = self;
    
    // Comment-in to disable ads
//    self.bannerView.hidden = YES;
    
    self.movie = NO;
    
    // Temporary - for appstore screenshots only
//    self.menuButton.hidden = YES;
//    self.retryButton.hidden = YES;
//    self.bestScoreTextLabel.hidden = YES;
//    self.bestScoreLabel.hidden = YES;
    
    self.recolorMode = NO;
    
    if (self.movie) {
        self.bannerView.hidden = YES;
        [self.menuButton setTitle:@"Solve" forState:UIControlStateNormal];
        self.retryButton.hidden = YES;
    }

    // This code is standard mode!!!
    
    [self start];
    
    // Future TODO: purchase the hint package: keep all possible solutions and on every long-press show the current relevant end-cells.
    // Future TODO: purchase the hint package deluxe: on every level advance (or step?) alert when full game completion is no longer possible.
}

- (void)start
{
    if (self.movie) {
        [self resetBoard:STARTING_NUM_COLS numRows:STARTING_NUM_ROWS];
        return;
    }
    
    [self.gameManager load];
    [self.gameStatistics load];
    
    if (self.gameManager.singlesMode) {
        // No need to start at home - file is loaded successfully
        [self startSinglesMode];
    }
    else {
        //    [self.gameInfo deleteGameInfoFile];
        
        [self resetBoard:STARTING_NUM_COLS numRows:STARTING_NUM_ROWS];
        
        BOOL loadSuccess = [self loadFromGameInfo];
        
        if (!loadSuccess) {
            [self startHome];
        }
        else {
            [self endMove];
        }
    }
    
    // Must call here - after menu buttons are all set properly
    if (!self.gameManager.soundIsOn) {
        [self.menuSoundToggleButton setTitle:@"Sound: Off" forState:UIControlStateNormal];
    }
}

- (void)startHome
{
    self.menuIsOn = YES;
    
    [self showAndEnableButtons:self.homeButtons];
    for (UIButton *button in self.homeButtons) {
        button.alpha = 1.0;
    }
    
    self.moveSwipeAllowed = NO;
    self.retryButton.enabled = NO;
    self.menuButton.enabled = NO;
    
    if (![self.board canFinishInIndex:self.board.curIndex]) {
        [self.labelsGrid[self.board.curIndex] setHidden:YES];
    }
                         
    self.curCell.alpha = 0.0;
    
    for (NSUInteger index = 0; index < [self.board numCells]; index++) {
        [self.grid[index] setAlpha:0.0];
        [self.labelsGrid[index] setAlpha:0.0];
    }
    
    for (UIView *gridLine in self.gridLines) {
        gridLine.alpha = 0.0;
    }
    
    [self setAlphaToScoreLabelsAndButtonsAndZeroAlphaForGameOverLabel:0.0];
    
    for (UIButton *button in self.gameCompletionButtons) {
        button.alpha = 0.0;
    }
}

- (void)loadBoardSinglesLevel
{
    [self.board setSinglesModeLevel:[self.singlesModeManager getLevelStartIndex]
                        finishIndex:[self.singlesModeManager getLevelFinishIndex]];
}

- (void)startSinglesMode
{
    [self.singlesModeManager load];
    
    if ([self.singlesModeManager levelGridIs4x4]) {
        [self resetBoard:STARTING_NUM_COLS numRows:STARTING_NUM_ROWS];
    }
    else {
        [self resetBoard:STARTING_NUM_COLS+1 numRows:STARTING_NUM_ROWS+1];
    }
    
    self.gameIsCompleted = NO;
    
    [self loadBoardSinglesLevel];
    [self setSinglesModeMenuButtons];
    [self setSinglesModeLabels];
    
    [self loadBoardView];
//    [self.singlesModeManager hack];
    [self endMove];
}

- (BOOL)loadFromGameInfo
{
    BOOL loadSuccess = [self.gameInfo loadInfoFromFile];
    
    if (loadSuccess) {
        if ([self.gameInfo curGridSize] != self.board.numCols) {
            [self resetBoard:[self.gameInfo curGridSize] numRows:[self.gameInfo curGridSize]];
        }
        [self.gameInfo loadBoardFromInfo:self.board];
        [self loadBoardView];
        if ([self.gameInfo maxGridSize] != STARTING_NUM_COLS || [self.gameInfo bestScore] >= 240) {
            [self setAdvancedMenuButtons];
        }
    }
    
    return loadSuccess;
}

- (void)loadBoardView
{
    [self updateScoreLabels];
    [self updateTitleFontSize];
    [self colorBestScoreLabels];
    
    [self resetLevelCellsView];
    [self updateCurCell];
    
    for (NSUInteger index = 0; index < [self.board numCells]; index++) {
        if (![self.board cellInIndexIsFree:index] && index != self.board.curIndex) {
            [self.grid[index] setBackgroundColor:(__bridge CGColorRef)([The240GameViewController blockedCellColor])];
        }
    }
    
    // TODO: change to remember which frowney it is and make sure to rotate the label accordingly.
    //  Can be reporoduced by killing the app in a lost board, are by toggling between lost boards. Small and silly bug.
    [self randomizeGameOverLabel];
    
    [self restoreLostBoardViewIfNeeded];
}

- (void)addBoardFrame
{
    CGFloat frameWidth = 7.0;
    CGPoint origin = CGPointMake(self.boardView.bounds.origin.x - frameWidth, self.boardView.bounds.origin.y - frameWidth);
    
    CGSize gridSize = [self getGridSize];
    CGFloat frameSizeWidth = gridSize.width * self.board.numCols + frameWidth;
    CGFloat frameSizeHeight = gridSize.height * self.board.numRows + frameWidth;
    
    NSArray *boardFrames = @[[[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, frameSizeWidth, frameWidth)],
                             [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y + frameWidth, frameWidth, frameSizeHeight)],
                             [[UIView alloc] initWithFrame:CGRectMake(origin.x + frameWidth, origin.y + frameSizeHeight, frameSizeWidth, frameWidth)],
                             [[UIView alloc] initWithFrame:CGRectMake(origin.x + frameSizeWidth, origin.y, frameWidth, frameSizeHeight)]];
    for (UIView *boardFrame in boardFrames) {
        boardFrame.backgroundColor = [The240GameViewController baseGameColor];
        [self.boardView insertSubview:boardFrame atIndex:0];
        [self.frames addObject:boardFrame];
    }
}

- (void)updateHelpTextLabel
{
    self.helpTextLabel.frame = CGRectMake(0, 0, self.boardView.frame.size.width, self.boardView.frame.size.height);
    [self.helpTextLabel setTextAlignment:NSTextAlignmentCenter];
    [self.helpTextLabel setNumberOfLines:8];
    [self.boardView addSubview:self.helpTextLabel];
}

#pragma mark Sounds

- (void)setSounds
{
    SystemSoundID sound;
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/click.mp3", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &sound);
    self.moveSound = sound;

    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/whis-up4.mp3", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &sound);
    self.toggleGridSizeSound = sound;

    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/whis-in2.mp3", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &sound);
    self.retrySound = sound;

    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/tata.mp3", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &sound);
    self.levelAdvanceSound = sound;

    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/whis-down.mp3", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &sound);
    self.goBackOneLevelSound = sound;
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/mmmg.mp3", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &sound);
    self.cantMoveSound = sound;

    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/prr3.mp3", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &sound);
    self.lostSound = sound;

    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/helptextin.mp3", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &sound);
    self.menuInSound = sound;
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/the_end2.mp3", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &sound);
    self.completedTheGameSound = sound;
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/game3.mp3", [[NSBundle mainBundle] resourcePath]]]; // TODO: will not work for sounds longer than 30 seconds
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &sound);
    self.movieSound = sound;
}

- (void)playSound:(SystemSoundID) soundId
{
    if (self.gameManager.soundIsOn && !self.movie) {
        AudioServicesPlaySystemSound(soundId);
    }
}

#pragma mark Labels and buttons colors and fonts

#define HELP_TEXT_FONT_SIZE 27
#define SKIP_TEXT_FONT_SIZE 27

- (void)setFontsAndButtons
{
    self.scoreTitleLabel.font = [The240GameViewController gameFontWithSize:54];
    self.slashTitleLabel.font = [The240GameViewController gameFontWithSize:54];
    self.maxScoreTitleLabel.font = [The240GameViewController gameFontWithSize:54];
    
    self.helpTextLabel.font = [The240GameViewController gameFontWithSize:HELP_TEXT_FONT_SIZE];
    self.helpTextLabel.hidden = YES;
    self.helpTextNextLabel.font = [The240GameViewController gameFontWithSize:35];
    self.helpTextNextLabel.hidden = YES;
    self.helpTextBackButton.titleLabel.font = [The240GameViewController gameFontWithSize:35];
    
    self.bestScoreTextLabel.font = [The240GameViewController gameFontWithSize:20];
    self.bestScoreLabel.font = [The240GameViewController gameFontWithSize:20];
    
    [self setLabelsColor:@[self.scoreTitleLabel, self.slashTitleLabel, self.maxScoreTitleLabel, self.helpTextLabel, self.helpTextNextLabel,
                           self.bestScoreTextLabel, self.bestScoreLabel] withColor:[The240GameViewController baseGameColor]];
    
    self.retryButton.titleLabel.font = [The240GameViewController gameFontWithSize:34];
    self.menuButton.titleLabel.font = [The240GameViewController gameFontWithSize:20];
    self.helpTextSkipButton.titleLabel.font = [The240GameViewController gameFontWithSize:SKIP_TEXT_FONT_SIZE];
    
    [self hideAndDisableButtons:@[self.helpTextSkipButton, self.helpTextBackButton]];
    
    [self setButtonsColor:@[self.retryButton, self.menuButton, self.helpTextSkipButton, self.helpTextBackButton] withColor:[The240GameViewController baseGameColor]];
    
    [self setBasicMenuButtons];
    
    [self setRestartMenuButtons];
}

- (void)setLabelsColor:(NSArray *)labels withColor:(UIColor *)color
{
    for (UILabel *label in labels) {
        label.textColor = color;
    }
}

- (void)setButtonsColor:(NSArray *)buttons withColor:(UIColor *)color
{
    for (UIButton *button in buttons) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
}

- (void)setHowToPlayText
{
    self.howToPlayTextView.textColor = [The240GameViewController baseGameColor];
    self.howToPlayTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.howToPlayTextView.hidden = YES;
    self.howToPlayTextView.selectable = NO;
    
    [self setHowToPlayStandardModeText];
}

- (void)setHowToPlayStandardModeText
{
    self.howToPlayTextView.text = @"How to play the 240 game:\n\n"
    "Slide the orange square around the board and try to visit every cell once. "
    "Every visited cell will be blocked after sliding to the next cell. "
    "The board is solved when all of the cells are blocked.\n\n"
    "After you successfully solve the board - the board will be cleared and you will have to solve it again, "
    "starting from the cell you just finished in.\n\n"
    "The goal of the 240 game is to solve the board 16 times - each time starting from the cell you just finished in "
    "and finishing in a different cell. "
    "After you solve the board - continue to solve it again and again until you have finished exactly one time in every cell. "
    "This takes exactly 240 moves.\n\n"
    "Cells you have already finished in will be marked with ✔︎. This means you must still visit these cells when solving the board, "
    "but you cannot finish there anymore for the rest of the game.\n\n"
    "Click on ↺ will restart this level. You can go back one level or restart the game from the menu.\n\n"
    "Notice: not all cells are possible to finish in when starting from a certain cell. "
    "A long press on the board shows the possible finishing cells of this level.\n\nGood luck!";
}

- (void)setHowToPlaySinglesModeText
{
    self.howToPlayTextView.text = @"The 240 game - singles mode:\n\n"
    "Slide the orange square around the board and try to visit every cell once. "
    "Every visited cell will be blocked after sliding to the next cell. "
    "The board is solved when all of the cells are blocked.\n\n"
    "Notice: the cell marked with the organe circle must be the last cell you visit.\n\n"
    "Click on ↺ will restart this level. You can go back and forth between levels from the menu.\n\n"
    "Good luck!";
}

- (void)initHomeButtons
{
    CGFloat verticalOffset = 50.0;
    
    CGFloat height = (self.boardView.frame.size.height - 2 * verticalOffset) / 2;
    
    UIButton *standardModeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [standardModeButton addTarget:self action:@selector(play240FromHome:) forControlEvents:UIControlEventTouchUpInside];
    [standardModeButton setTitle:@"Play 240" forState:UIControlStateNormal];
    [standardModeButton setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
    standardModeButton.titleLabel.font = [The240GameViewController gameFontWithSize:40];
    standardModeButton.frame = CGRectMake(0, verticalOffset, self.boardView.frame.size.width, height);
    [self.homeButtons addObject:standardModeButton];
    [self.boardView addSubview:standardModeButton];
    
    UIButton *singlesModeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [singlesModeButton addTarget:self action:@selector(playSinglesModeFromHome:) forControlEvents:UIControlEventTouchUpInside];
    [singlesModeButton setTitle:@"Singles Mode" forState:UIControlStateNormal];
    [singlesModeButton setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
    singlesModeButton.titleLabel.font = [The240GameViewController gameFontWithSize:30];
    singlesModeButton.frame = CGRectMake(0, verticalOffset + height, self.boardView.frame.size.width, height);
    [self.homeButtons addObject:singlesModeButton];
    [self.boardView addSubview:singlesModeButton];
    
    CGFloat widthFactor = 0.75;
    self.homeNewLabel.frame = CGRectMake(self.boardView.frame.size.width * widthFactor, verticalOffset + height * 2 - 22,
                                         self.boardView.frame.size.width * (1-widthFactor), 22);
    self.homeNewLabel.text = @"New!";
    self.homeNewLabel.textColor = [The240GameViewController curCellColor];
    self.homeNewLabel.font = [The240GameViewController gameFontWithSize:16.0];
    self.homeNewLabel.alpha = 0.0;
    self.homeNewLabel.hidden = YES;
    [self.boardView addSubview:self.homeNewLabel];
    
    [self addShareRateButtons];

    [self hideAndDisableButtons:self.homeButtons];
}

#define MENUS_HORIZONTAL_OFFSET 0.0
#define MENUS_VERTICAL_OFFSET 20.0
#define MENUS_FONT_SIZE 30.0

- (void)setBasicMenuButtons
{
    NSAssert(!self.gameManager.singlesMode, @"Can't call in singles mode");
    
    [self.menuButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.menuButtons removeAllObjects];
    
    NSArray *buttonsTitles = @[@"How To Play", @"Sound: On", @"Back One Level", @"Restart Game"];
    
    NSUInteger numButtons = [buttonsTitles count];
    
    CGFloat height = (self.boardView.frame.size.height - 2 * MENUS_VERTICAL_OFFSET) / numButtons;
    
    for (NSUInteger i = 0; i < numButtons; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:buttonsTitles[i] forState:UIControlStateNormal];
        [button setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
        button.titleLabel.font = [The240GameViewController gameFontWithSize:MENUS_FONT_SIZE];
        button.frame = CGRectMake(MENUS_HORIZONTAL_OFFSET, MENUS_VERTICAL_OFFSET + height * i,
                                  self.boardView.frame.size.width - MENUS_HORIZONTAL_OFFSET, height);
        [self.boardView addSubview:button];
        [self.menuButtons addObject:button];
    }
    
    [self.menuButtons[0] addTarget:self action:@selector(menuHowToPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons[1] addTarget:self action:@selector(menuSoundToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons[2] addTarget:self action:@selector(menuGoBackOneLevel:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons[3] addTarget:self action:@selector(menuRestartGame:) forControlEvents:UIControlEventTouchUpInside];
    
    self.menuSoundToggleButton = self.menuButtons[1];
    
    [self addTopRightExitMenuButton];
    [self addDeleteInfoFileHackIfNeededToRestartButton:self.menuButtons[3]];
    
    [self hideAndDisableMenuButtons];
}

- (void)addTopRightExitMenuButton
{
    UIButton *exitMenuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [exitMenuButton addTarget:self action:@selector(exitMenu:) forControlEvents:UIControlEventTouchUpInside];
    [exitMenuButton setTitle:self.helpTextSkipButton.titleLabel.text forState:UIControlStateNormal];
    [exitMenuButton setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
    exitMenuButton.titleLabel.font = [The240GameViewController gameFontWithSize:SKIP_TEXT_FONT_SIZE];
    exitMenuButton.frame = self.helpTextSkipButton.frame;
    [self.boardView addSubview:exitMenuButton];
    [self.menuButtons addObject:exitMenuButton];
}

#define TOP_BUTTONS_FONT_SIZE 30.0

- (void)addShareRateButtons
{
    [self.shareButton setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
    self.shareButton.titleLabel.font = [The240GameViewController gameFontWithSize:TOP_BUTTONS_FONT_SIZE];
    [self.homeButtons addObject:self.shareButton];

    [self.rateButton setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
    self.rateButton.titleLabel.font = [The240GameViewController gameFontWithSize:TOP_BUTTONS_FONT_SIZE];
    [self.homeButtons addObject:self.rateButton];
}

- (void)setRestartMenuButtons
{
    CGFloat horisontalOffset = 20.0;
    CGFloat verticalOffset = 200.0;
    
    CGFloat width = (self.boardView.frame.size.width - 2 * horisontalOffset) / 2;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton addTarget:self action:@selector(menuRestartCancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [The240GameViewController gameFontWithSize:HELP_TEXT_FONT_SIZE];
    cancelButton.frame = CGRectMake(horisontalOffset, verticalOffset, width, self.boardView.frame.size.height - verticalOffset);
    [self.restartButtons addObject:cancelButton];
    [self.boardView addSubview:cancelButton];
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [okButton addTarget:self action:@selector(menuRestartOK:) forControlEvents:UIControlEventTouchUpInside];
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [okButton setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
    okButton.titleLabel.font = [The240GameViewController gameFontWithSize:HELP_TEXT_FONT_SIZE];
    okButton.frame = CGRectMake(horisontalOffset + width + 10.0, verticalOffset, width, self.boardView.frame.size.height - verticalOffset);
    [self.restartButtons addObject:okButton];
    [self.boardView addSubview:okButton];
    
    [self hideAndDisableButtons:self.restartButtons];
}

- (void)addDeleteInfoFileHackIfNeededToRestartButton:(UIButton *)restartButton
{
    if (self.deleteInfoFileHack) {
        NSLog(@"Adding delete info file hack");
        UILongPressGestureRecognizer *hack = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteInfoFileHackLongPress:)];
        [restartButton addGestureRecognizer:hack];
    }
}

- (void)setAdvancedMenuButtons
{
    NSAssert(!self.gameManager.singlesMode, @"Can't call in singles mode");
    
    [self.menuButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.menuButtons removeAllObjects];
    
    NSArray *buttonsTitles = @[@"How To Play",
                               @"Sound: On",
                               [The240GameViewController getToggleGridSizeButtonTitle:[self getGridSizeAfterToggle:self.board.numCols]],
                               @"Back One Level",
                               @"Restart Game"];
    
    NSUInteger numButtons = [buttonsTitles count];
    
    CGFloat height = (self.boardView.frame.size.height - 2 * MENUS_VERTICAL_OFFSET) / numButtons;
    
    for (NSUInteger i = 0; i < numButtons; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:buttonsTitles[i] forState:UIControlStateNormal];
        [button setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
        button.titleLabel.font = [The240GameViewController gameFontWithSize:MENUS_FONT_SIZE];
        button.frame = CGRectMake(MENUS_HORIZONTAL_OFFSET, MENUS_VERTICAL_OFFSET + height * i,
                                  self.boardView.frame.size.width - MENUS_HORIZONTAL_OFFSET, height);
        [self.boardView addSubview:button];
        [self.menuButtons addObject:button];
    }
    
    [self.menuButtons[0] addTarget:self action:@selector(menuHowToPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons[1] addTarget:self action:@selector(menuSoundToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons[2] addTarget:self action:@selector(toggleGridSizeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons[3] addTarget:self action:@selector(menuGoBackOneLevel:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons[4] addTarget:self action:@selector(menuRestartGame:) forControlEvents:UIControlEventTouchUpInside];

    self.menuSoundToggleButton = self.menuButtons[1];
    self.gridSizeTogglingButton = self.menuButtons[2];
    
    [self colorGridSizeTogglingButton:[self getGridSizeAfterToggle:self.board.numCols]];
    
    [self addTopRightExitMenuButton];
    [self addDeleteInfoFileHackIfNeededToRestartButton:self.menuButtons[4]];
    
    [self hideAndDisableMenuButtons];
}

- (void)setSinglesModeMenuButtons
{
    NSAssert(self.gameManager.singlesMode, @"Must call in singles mode");
    
    [self.menuButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.menuButtons removeAllObjects];
    
    NSArray *buttonsTitles = @[@"How To Play", @"Sound: On", @"Go To Level:", @"DUMMY BUTTON"];
    
    NSUInteger numButtons = [buttonsTitles count];
    
    CGFloat height = (self.boardView.frame.size.height - 2 * MENUS_VERTICAL_OFFSET) / numButtons;
    
    for (NSUInteger i = 0; i < numButtons-1; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:buttonsTitles[i] forState:UIControlStateNormal];
        [button setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
        button.titleLabel.font = [The240GameViewController gameFontWithSize:MENUS_FONT_SIZE];
        button.frame = CGRectMake(MENUS_HORIZONTAL_OFFSET, MENUS_VERTICAL_OFFSET + height * i,
                                  self.boardView.frame.size.width - MENUS_HORIZONTAL_OFFSET, height);
        [self.boardView addSubview:button];
        [self.menuButtons addObject:button];
    }
    
    [self.menuButtons[0] addTarget:self action:@selector(menuHowToPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons[1] addTarget:self action:@selector(menuSoundToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons[2] setEnabled:NO];
    
    // Add First/Prev/Next/Last level changing buttons:
    
    NSArray *levelsChangingButtonsTitles = @[@"«", @"‹", @"›", @"»"];
    
    NSUInteger numLevelChangingButtons = [levelsChangingButtonsTitles count];
    
    CGFloat width = (self.boardView.frame.size.width - 2 * MENUS_HORIZONTAL_OFFSET) / numLevelChangingButtons;
    
    for (NSUInteger i = 0; i < numLevelChangingButtons; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:levelsChangingButtonsTitles[i] forState:UIControlStateNormal];
        [button setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
        button.titleLabel.font = [The240GameViewController gameFontWithSize:50];
        button.frame = CGRectMake(MENUS_HORIZONTAL_OFFSET + width * i, MENUS_VERTICAL_OFFSET + height * (numButtons-1), width, height);
        [self.boardView addSubview:button];
        [self.menuButtons addObject:button];
    }
    
    [self.menuButtons[3] addTarget:self action:@selector(menuSinglesModeFirstLevel:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons[4] addTarget:self action:@selector(menuSinglesModePreviousLevel:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons[5] addTarget:self action:@selector(menuSinglesModeNextLevel:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons[6] addTarget:self action:@selector(menuSinglesModeLastLevel:) forControlEvents:UIControlEventTouchUpInside];
    
    self.menuSoundToggleButton = self.menuButtons[1];
    self.singlesModeFirstButton = self.menuButtons[3];
    self.singlesModePrevButton = self.menuButtons[4];
    self.singlesModeNextButton = self.menuButtons[5];
    self.singlesModeLastButton = self.menuButtons[6];
    
    [self updateSingleModeNextPrevButtons];
    
    [self addTopRightExitMenuButton];
    [self addDeleteInfoFileHackIfNeededToRestartButton:self.menuButtons[3]];
    
    [self hideAndDisableMenuButtons];
}

- (void)updateSingleModeNextPrevButtons
{
    NSAssert(self.gameManager.singlesMode, @"Must call in singles mode");
    
    if (self.singlesModeManager.curLevel == 0) {
        self.singlesModePrevButton.enabled = NO;
        self.singlesModePrevButton.alpha = 0.5;
        self.singlesModeFirstButton.enabled = NO;
        self.singlesModeFirstButton.alpha = 0.5;
    }
    else {
        self.singlesModePrevButton.enabled = YES;
        self.singlesModePrevButton.alpha = 1.0;
        self.singlesModeFirstButton.enabled = YES;
        self.singlesModeFirstButton.alpha = 1.0;
    }
    
    if (self.singlesModeManager.curLevel == self.singlesModeManager.maxLevel) {
        self.singlesModeNextButton.enabled = NO;
        self.singlesModeNextButton.alpha = 0.5;
        self.singlesModeLastButton.enabled = NO;
        self.singlesModeLastButton.alpha = 0.5;
    }
    else {
        self.singlesModeNextButton.enabled = YES;
        self.singlesModeNextButton.alpha = 1.0;
        self.singlesModeLastButton.enabled = YES;
        self.singlesModeLastButton.alpha = 1.0;
    }
    
    // "Go To Level:" functions as a label, not a button
    [self.menuButtons[2] setEnabled:NO];
}

- (void)colorGridSizeTogglingButton:(NSUInteger)gridSize
{
    if (gridSize == [self.gameInfo maxGridSize]) {
        [self.gridSizeTogglingButton setTitleColor:[The240GameViewController gridTogglingMenuButtonColor] forState:UIControlStateNormal];
    }
    else {
        [self.gridSizeTogglingButton setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
    }
}

- (void)setGameIsCompletedButtons
{
    NSAssert(!self.gameManager.singlesMode, @"Can't call in singles mode");
    
    [self.gameCompletionButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.gameCompletionButtons removeAllObjects];
    
    CGFloat verticalOffset = 50.0;
    
    CGFloat height = (self.boardView.frame.size.height - 2 * verticalOffset) / 2;
    
    UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [toggleButton addTarget:self action:@selector(toggleGridSizeButton:) forControlEvents:UIControlEventTouchUpInside];
    [toggleButton setTitle:[The240GameViewController getToggleGridSizeButtonTitle:self.board.numCols + 1] forState:UIControlStateNormal];
    [toggleButton setTitleColor:[The240GameViewController gridTogglingMenuButtonColor] forState:UIControlStateNormal];
    toggleButton.titleLabel.font = [The240GameViewController gameFontWithSize:40];
    toggleButton.frame = CGRectMake(0, verticalOffset, self.boardView.frame.size.width, height);
    [self.gameCompletionButtons addObject:toggleButton];
    [self.boardView addSubview:toggleButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [shareButton setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
    shareButton.titleLabel.font = [The240GameViewController gameFontWithSize:40];
    shareButton.frame = CGRectMake(0, verticalOffset + height, self.boardView.frame.size.width, height);
    [self.gameCompletionButtons addObject:shareButton];
    [self.boardView addSubview:shareButton];
}

- (void)setSinglesGameIsCompletedButtons
{
    NSAssert(self.gameManager.singlesMode, @"Must call in singles mode");
    
    [self.gameCompletionButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.gameCompletionButtons removeAllObjects];
    
    BOOL singlesGameIsFullyCompleted = self.singlesModeManager.maxLevel == [self.singlesModeManager numLevels];
    
    NSArray *buttonsTitles = singlesGameIsFullyCompleted ? @[@"240", @"Share"] : @[@"240", @"More Singles", @"Share"];
    
    NSUInteger numButtons = [buttonsTitles count];
    
    CGFloat height = (self.boardView.frame.size.height - 2 * MENUS_VERTICAL_OFFSET) / numButtons;
    
    for (NSUInteger i = 0; i < numButtons; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:buttonsTitles[i] forState:UIControlStateNormal];
        [button setTitleColor:[The240GameViewController baseGameColor] forState:UIControlStateNormal];
        button.titleLabel.font = [The240GameViewController gameFontWithSize:MENUS_FONT_SIZE];
        button.frame = CGRectMake(MENUS_HORIZONTAL_OFFSET, MENUS_VERTICAL_OFFSET + height * i,
                                  self.boardView.frame.size.width - MENUS_HORIZONTAL_OFFSET, height);
        [self.boardView addSubview:button];
        [self.gameCompletionButtons addObject:button];
    }
    
    [self.gameCompletionButtons[0] setTitleColor:[The240GameViewController gridTogglingMenuButtonColor] forState:UIControlStateNormal];
    
    [self.gameCompletionButtons[0] addTarget:self action:@selector(play240FromSingleModeCompletion:) forControlEvents:UIControlEventTouchUpInside];
    
    if (singlesGameIsFullyCompleted) {
        [self.gameCompletionButtons[1] addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self.gameCompletionButtons[1] addTarget:self action:@selector(moreSinglesGameCompletionButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.gameCompletionButtons[2] addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)hideAndDisableButtons:(NSArray *)buttons
{
    for (UIButton *button in buttons) {
        button.enabled = NO;
        button.hidden = YES;
        button.alpha = 0.0;
    }
}

- (void)hideAndDisableMenuButtons
{
    [self hideAndDisableButtons:self.menuButtons];
    [self hideAndDisableButtons:@[self.homeButton]];
}

- (void)showAndEnableButtons:(NSArray *)buttons
{
    // Notice: function doesn't modify alpha
    
    for (UIButton *button in buttons) {
        button.enabled = YES;
        button.hidden = NO;
    }
}

- (void)setAlphaToScoreLabelsAndButtonsAndZeroAlphaForGameOverLabel:(float)alpha
{
    [self setAlphaToScoreLabelsAndButtons:alpha];
    self.gameOverLabel.alpha = 0.0;
}

- (void)setAlphaToScoreLabelsAndButtons:(float)alpha
{
    self.scoreTitleLabel.alpha = alpha;
    self.slashTitleLabel.alpha = alpha;
    self.maxScoreTitleLabel.alpha = alpha;
    
    self.bestScoreTextLabel.alpha = alpha;
    self.bestScoreLabel.alpha = alpha;
    
    self.retryButton.alpha = alpha;
    self.menuButton.alpha = alpha;
}

#pragma mark Disable rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark Board view init methods

- (void)clearGridItems
{
    [self.grid makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.grid removeAllObjects];
    [self.labelsGrid removeAllObjects];
    
    [self.gridLines makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.gridLines removeAllObjects];
}

- (void)resetBoard:(NSUInteger)numCols numRows:(NSUInteger)numRows
{
    NSLog(@"Call reset board");
    
    // If grid cells and line exist - clear
    [self clearGridItems];
    
    // Init new board with input number of cols and rows
    self.board = [[Board alloc] initWithNumCols:numCols numRows:numRows]; // TODO: maybe memory leak here after few calls of resetBoard? Is old board memory freed?

    // Init grid cells according to new board
    for (NSUInteger index = 0; index < [self.board numCells]; index++) {
        CGRect frame;
        frame.origin = [self indexToPosition:index];
        frame.size = [self getGridSize];
        UIView *cell = [[UIView alloc] initWithFrame:frame];
        cell.backgroundColor = [The240GameViewController freeCellColor];
        [self.grid addObject:cell];
        [self.boardView addSubview:cell];
        
        UILabel *label = [self newGridLabel:cell.bounds :self.board.numCols];
        [self.labelsGrid addObject:label];
        [cell addSubview:label];
    }
    if (self.gameManager.singlesMode) {
        [self setSinglesModeLabels];
    }
    else {
        [self setStandardModeLabels];
    }
    
    // Update according to board
    [self updateCurCell];
    
    // Cells order: lowest are the grid cells, then the main cur cell and on top the grid lines.
    [self.boardView bringSubviewToFront:self.curCell];
    [self addDrawGridSubviews];
    
    [self resetGameOverLabel];
    [self resetLevelAdvanceLabel];
    
    [self updateScoreLabels];
    
    [self.boardView bringSubviewToFront:self.helpTextLabel];
    [self.boardView bringSubviewToFront:self.helpTextNextLabel];
    [self.boardView bringSubviewToFront:self.helpTextBackButton];
}

- (void)addDrawGridSubviews
{
    CGSize gridSize = [self getGridSize];
    CGFloat lineWidth = 0.5;
    
    CGSize verticalLineSize = CGSizeMake(lineWidth, gridSize.height * self.board.numRows);
    CGRect verticalLineFrame;
    verticalLineFrame.origin = self.boardView.bounds.origin;
    verticalLineFrame.size = verticalLineSize;
    
    for (NSUInteger i = 0; i < self.board.numCols + 1; i++) {
        UIView *verticalLineSubview = [[UIView alloc] initWithFrame:verticalLineFrame];
        verticalLineSubview.backgroundColor = [The240GameViewController baseGameColor];
        [self.gridLines addObject:verticalLineSubview];
        [self.boardView addSubview:verticalLineSubview];
        verticalLineFrame.origin.x += gridSize.width;
    }
    
    CGSize horizontalLineSize = CGSizeMake(gridSize.width * self.board.numCols, lineWidth);
    CGRect horizontalLineFrame;
    horizontalLineFrame.origin = self.boardView.bounds.origin;
    horizontalLineFrame.size = horizontalLineSize;
    
    for (NSUInteger i = 0; i < self.board.numRows + 1; i++) {
        UIView *horizontalLineSubview = [[UIView alloc] initWithFrame:horizontalLineFrame];
        horizontalLineSubview.backgroundColor = [The240GameViewController baseGameColor];
        [self.gridLines addObject:horizontalLineSubview];
        [self.boardView addSubview:horizontalLineSubview];
        horizontalLineFrame.origin.y += gridSize.height;
    }
}

- (void)updateCurCell
{
    CGRect frame;
    frame.origin = [self indexToPosition:self.board.curIndex];
    frame.size = [self getGridSize];
    self.curCell.frame = frame;
    self.curCell.backgroundColor = [The240GameViewController curCellColor];
}

#pragma mark Labels

- (void)randomizeGameOverLabel
{
    [self.gameOverLabel removeFromSuperview];
    
    NSArray *lostTexts = @[@":(", @":[", @":/", @":O", @":0", @":o", @":|", @":l",
                           @"=(", @"=[", @"=/", @"=0", @"=o", @"8(", @"8[", @"8l",
                           @":-(", @":-{", @":^(", @":-[", @":-/", @":-|", @":-l", @":-o", @":-0", @"=-(", @"=-[", @"x-(",
                           @"'_'", @"☹",  @"⍤", @"⍨"];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    self.gameOverLabel.transform = transform;
    self.gameOverLabel.bounds = CGRectMake(0, 0, self.boardView.bounds.size.width, self.boardView.bounds.size.height);
    
    NSUInteger numLostText = [lostTexts count];
    NSUInteger numNoNeedToRotate = 4;
    
    NSUInteger lostTextIndex = 0;
    
    static BOOL lostFirstTime = YES;
    if (!lostFirstTime) {
        lostTextIndex = arc4random() % numLostText;
    }
    lostFirstTime = NO;
    
    self.gameOverLabel.text = lostTexts[lostTextIndex];
    
    if (lostTextIndex < numLostText - numNoNeedToRotate) {
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        self.gameOverLabel.transform = transform;
        self.gameOverLabel.bounds = CGRectMake(0, 0, self.boardView.bounds.size.width, self.boardView.bounds.size.height);
    }
    
    [self.boardView addSubview:self.gameOverLabel];
}

- (void)resetGameOverLabel
{
    self.gameOverLabel.font = [The240GameViewController gameFontWithSize:200];
    self.gameOverLabel.textColor = [The240GameViewController baseGameColor];
    self.gameOverLabel.textAlignment = NSTextAlignmentCenter;
    self.gameOverLabel.hidden = YES;
    self.gameOverLabel.alpha = 0.0;
    [self.boardView bringSubviewToFront:self.gameOverLabel];
}

- (void)resetLevelAdvanceLabel
{
    self.bigLevelAdvanceLabel.font = [The240GameViewController advanceLevelLabelFont:200];
    self.bigLevelAdvanceLabel.textColor = [The240GameViewController advanceLevelLabelColor];
    self.bigLevelAdvanceLabel.hidden = YES;
    self.bigLevelAdvanceLabel.alpha = 0.0;
    [self.boardView bringSubviewToFront:self.bigLevelAdvanceLabel];
}

- (UILabel *)newGridLabel:(CGRect)rect :(NSUInteger)numCols
{
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    
    NSUInteger fontSize = 65 * 4 / numCols; // For "X" use 45 * 4 / numCols;
    label.font = [The240GameViewController gameFontWithSize:fontSize];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.hidden = YES;
    
    return label;
}

- (void)setStandardModeLabels
{
    for (UILabel *label in self.labelsGrid) {
        label.text = @"✔︎"; //@"✖︎";
        label.textColor = [The240GameViewController baseGameColor];
    }
}

- (void)setSinglesModeLabels
{
    for (UILabel *label in self.labelsGrid) {
        label.text = @"●";
        label.textColor = [The240GameViewController curCellColor];
    }
}

#pragma mark Grid methods

- (CGPoint)indexToPosition:(NSUInteger)index
{
    CGSize gridSize = [self getGridSize];
    NSUInteger rowIndex = index / self.board.numRows;
    NSUInteger colIndex = index % self.board.numCols;
    return CGPointMake(gridSize.width * colIndex, gridSize.height * rowIndex);
}

- (CGPoint)indexToCenter:(NSUInteger)index
{
    CGSize gridSize = [self getGridSize];
    CGPoint res = [self indexToPosition:index];
    return CGPointMake(res.x + gridSize.width/2, res.y + gridSize.height/2);
}

- (CGSize)getGridSize
{
    CGFloat size = MIN(self.boardView.bounds.size.width / self.board.numCols, self.boardView.bounds.size.height / self.board.numRows);
    return CGSizeMake(size, size);
}

#pragma mark Advance stage and retry aiding methods

- (void)updateScoreLabels
{
    if (self.gameManager.singlesMode) {
        
        // Minor bug here: if moving back one level from 16 to 15 (from first 5x5 level to last 4x4 level) - the max level appears as 16 instead of 72.
        self.maxScoreTitleLabel.text = [NSString stringWithFormat:@"%lu",
                                        (unsigned long)(self.singlesModeManager.maxLevel == [self.singlesModeManager numLevels4x4] &&
                                                        self.board.numCols == STARTING_NUM_COLS ?
                                                        [self.singlesModeManager numLevels4x4] :
                                                        [self.singlesModeManager numLevels])];

        self.scoreTitleLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.singlesModeManager.curLevel];
        self.bestScoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.singlesModeManager.maxLevel];
    }
    else {
        self.maxScoreTitleLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self.board maxScore]];
        self.scoreTitleLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.board.score];
        self.bestScoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self.gameInfo bestScore]];
    }
}

- (void)colorBestScoreLabels
{
    if (!self.gameManager.singlesMode && [self.gameInfo bestScore] == [self.board maxScore]) {
        self.bestScoreLabel.textColor = [The240GameViewController gridTogglingMenuButtonColor];
    }
    else {
        self.bestScoreLabel.textColor = [The240GameViewController baseGameColor];
    }
}

#define LABELS_GRID_ALPHA 0.5

- (void)resetCellLabelView:(NSUInteger)index
{
    if (self.gameManager.singlesMode && index == self.board.singlesModeFinishIndex) {
        [self.labelsGrid[index] setHidden:NO];
        [self.labelsGrid[index] setAlpha:1.0];
    }
    else if (!self.gameManager.singlesMode && ![self.board canFinishInIndex:index]) {
        [self.labelsGrid[index] setHidden:NO];
        [self.labelsGrid[index] setAlpha:LABELS_GRID_ALPHA];
    }
    else {
        [self.labelsGrid[index] setHidden:YES];
        [self.labelsGrid[index] setAlpha:0.0];
    }
}

- (void)resetLevelCellsView
{
    for (NSUInteger index = 0; index < [self.board numCells]; index++) {
        [self resetCellLabelView:index];
        [self.grid[index] setBackgroundColor:(__bridge CGColorRef)([The240GameViewController freeCellColor])];
        [self.grid[index] setAlpha:1.0];
    }
    
    // This is necessary in case the game is completed:
    
    for (UIView *frame in self.frames) {
        frame.backgroundColor = self.recolorMode ? [self getLevelColor] : [The240GameViewController baseGameColor];
        frame.alpha = 1.0;
    }
    for (UIView *gridLine in self.gridLines) {
        gridLine.backgroundColor = self.recolorMode ? [self getLevelColor] : [The240GameViewController baseGameColor];
        gridLine.alpha = 1.0;
    }
}

#pragma mark Game completion

- (void)gameCompleted
{
    [self playSound:self.completedTheGameSound];
    
    self.gameIsCompleted = YES;
    
    [self.gameStatistics gameCompleted:[self.gameInfo curGridSize] solution:[self.gameInfo solution] gameCompletionBoardIndex:self.board.curIndex];
    
    // Condition is there to avoid several completions of 4x4 just to upgrade the grid size
    
    if ([self.gameInfo maxGridSize] == self.board.numCols) {
        
        // Don't toggle yet - toggle is done only by the button
        
        [self.gameInfo addEmptyBoardInfo];
    }
    
    // Save a clean board for this grid size
    
    [self.gameInfo restart:self.board];
    
    self.moveSwipeAllowed = NO;
    
    for (UILabel *label in self.labelsGrid) {
        label.alpha = 0.0;
    }
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.curCell.backgroundColor = [The240GameViewController blockedCellColor];
                     }
                     completion:^(BOOL finished){
                         [self animateBlinkAdvanceLabel:[self.board numCells] withDuration:1.2 blinkFrames:NO];
                         [UIView animateWithDuration:1.5
                                          animations:^{
                                              [self boardDisappear];
                                          }
                                          completion:^(BOOL finished){
                                              
                                              // Restore original colors, but with alpha 0.0
                                              
                                              [self resetLevelCellsView];
                                              
                                              for (UIView *frame in self.frames) {
                                                  frame.alpha = 0.0;
                                              }
                                              for (UIView *gridLine in self.gridLines) {
                                                  gridLine.alpha = 0.0;
                                              }
                                              for (UIView *cell in self.grid) {
                                                  cell.alpha = 0.0;
                                              }
                                              
                                              // Prepare new menu with grid toggling button
                                              
                                              [self animateGameCompletionTextAndUpdateMenus];
                                          }];
                     }];
}

#define GAME_COMPLETION_TEXT_DELAY 2.0

- (void)gameCompletedSinglesMode
{
    [self playSound:self.completedTheGameSound];
    
    self.gameIsCompleted = YES;
    
    self.moveSwipeAllowed = NO;
    
    for (UILabel *label in self.labelsGrid) {
        label.alpha = 0.0;
    }
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.curCell.backgroundColor = [The240GameViewController blockedCellColor];
                     }
                     completion:^(BOOL finished){
                         NSUInteger completionLabel = self.singlesModeManager.maxLevel == [self.singlesModeManager numLevels] ?
                         [self.singlesModeManager numLevels] :
                         [self.singlesModeManager numLevels4x4];
                         [self animateBlinkAdvanceLabel:completionLabel withDuration:1.2 blinkFrames:NO];
                         [UIView animateWithDuration:1.5
                                          animations:^{
                                              [self boardDisappear];
                                          }
                                          completion:^(BOOL finished){
                                              
                                              // Restore original colors, but with alpha 0.0
                                              
                                              [self resetLevelCellsView];
                                              
                                              for (UIView *frame in self.frames) {
                                                  frame.alpha = 0.0;
                                              }
                                              for (UIView *gridLine in self.gridLines) {
                                                  gridLine.alpha = 0.0;
                                              }
                                              for (UIView *cell in self.grid) {
                                                  cell.alpha = 0.0;
                                              }
                                              
                                              // Prepare new menu with grid toggling button
                                              
                                              if (self.board.numCols == 4) {
                                                  [self animateFadeInHelpTextArrayWithSkipButton:@[@"Congratulations!",
                                                                                                   @"You've completed the 240 game singles!",
                                                                                                   @"Did you solve the 240 game yet?",
                                                                                                   @"Now is your chance",
                                                                                                   @"Or you can continue with some more\ndifficult singles"] withDelay:GAME_COMPLETION_TEXT_DELAY];
                                              }
                                              else {
                                                  [self animateFadeInHelpTextArrayWithSkipButton:@[@"Wow",
                                                                                                   @"That was really impressive",
                                                                                                   @"You've completed all of the\nsingles levels!!!",
                                                                                                   @"Go tell your friends about it!",
                                                                                                   @"That was really great work",
                                                                                                   @"More levels to come in the future",
                                                                                                   @"You can always go back to the good old 240 game :)"] withDelay:GAME_COMPLETION_TEXT_DELAY];
                                              }
                                          }];
                     }];
}

- (void)boardDisappear
{
    for (UIView *subview in self.boardView.subviews) {
        subview.backgroundColor = [UIColor whiteColor];
    }
    
    self.bestScoreTextLabel.alpha = 0.0;
    self.bestScoreLabel.alpha = 0.0;
    
    self.menuButton.alpha = 0.0;
    self.retryButton.alpha = 0.0;
    
    self.gameOverLabel.backgroundColor = [UIColor clearColor];
    self.bigLevelAdvanceLabel.backgroundColor = [UIColor clearColor];
}

- (void)animateGameCompletionTextAndUpdateMenus
{
    NSAssert(self.board.numCols >= 4, @"Invalid board columns number");
    NSAssert([self.gameInfo maxGridSize] > 4, @"Max grid size must already be updated with the correct grid size");
    
    [self colorBestScoreLabels];
    [self setAdvancedMenuButtons]; // Also hides and disables the menu buttons. No problem of calling "twice", after the advanced menu buttons are already set.
    
    if (self.movie) {
        [self animateFadeInHelpTextArrayNoSkipButton:@[@"Thanks for playing!"] withDelay:GAME_COMPLETION_TEXT_DELAY];
        return;
    }
    
    // Future TODO: set a dedicated button for every available board grid size - don't use a single toggling button
    
    if (self.board.numCols == 4) {
        [self animateFadeInHelpTextArrayWithSkipButton:@[@"Congratulations!",
                                                         @"You've completed the 240 game!",
                                                         @"Now comes the real challenge",
                                                         @"The 600 game"] withDelay:GAME_COMPLETION_TEXT_DELAY];
    }
    else if (self.board.numCols == 5) {
        [self animateFadeInHelpTextArrayWithSkipButton:@[@"Wow",
                                                         @"That was really impressive",
                                                         @"Go collect\nyour prize",
                                                         @"The 1260 game"] withDelay:GAME_COMPLETION_TEXT_DELAY];
    }
    else {
        NSUInteger nextGridSize = self.board.numCols + 1;
        
        [self animateFadeInHelpTextArrayWithSkipButton:@[@"Unbelievable",
                                                         @"This is truly amazing",
                                                         @"You know what comes now",
                                                         [NSString stringWithFormat:@"The %lu game",
                                                          (unsigned long)[Board maxScore:nextGridSize numRows:nextGridSize]]] withDelay:GAME_COMPLETION_TEXT_DELAY];
    }
}

- (void)animateFadeOutTextGameIsCompleted
{
    // Restore no background to help text (background was modified to white in boardDisappear)
    
    self.helpTextLabel.backgroundColor = [UIColor clearColor];
    self.helpTextSkipButton.backgroundColor = [UIColor clearColor];
    self.helpTextNextLabel.backgroundColor = [UIColor clearColor];
    self.helpTextBackButton.backgroundColor = [UIColor clearColor];
    
    // Stay with an empty screen but allow menu button
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.menuButton.alpha = 1.0;
                         self.retryButton.alpha = 1.0;
                         self.bestScoreTextLabel.alpha = 1.0;
                         self.bestScoreLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         self.menuButton.enabled = YES;
                         self.retryButton.enabled = YES;
                     }];
    
    [self animateFadeInGameCompletionButtons];
}

- (void)animateFadeInGameCompletionButtons
{
    if (self.gameManager.singlesMode) {
        [self setSinglesGameIsCompletedButtons];
    }
    else {
        [self setGameIsCompletedButtons];
    }
    
    [self hideAndDisableButtons:self.gameCompletionButtons];
    
    [UIView animateWithDuration:0.4
                          delay:0.2
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self showAndEnableButtons:self.gameCompletionButtons];
                         for (UIButton *button in self.gameCompletionButtons) {
                             button.alpha = 1.0;
                         }
                     }
                     completion:^(BOOL finished) {}];
}

- (void)animateFadeOutGameCompletionButtons
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         for (UIButton *button in self.gameCompletionButtons) {
                             button.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         [self hideAndDisableButtons:self.gameCompletionButtons];
                     }];
}

#pragma mark Grid toggling

+ (NSString *)getToggleGridSizeButtonTitle:(NSUInteger) gridSize
{
    return [NSString stringWithFormat:@"%lux%lu", (unsigned long)gridSize, (unsigned long)gridSize];
}

- (void)updateToggleGridSizeMenuButtonTitle:(NSUInteger) gridSize
{
    [self.gridSizeTogglingButton setTitle:[The240GameViewController getToggleGridSizeButtonTitle:gridSize] forState:UIControlStateNormal];
    [self colorGridSizeTogglingButton:gridSize];
}

- (NSUInteger)getGridSizeAfterToggle:(NSUInteger) numCols
{
    NSAssert(self.board.numCols == self.board.numRows, @"Number of rows and columns is different - not supported");
    
    NSUInteger gridSize = STARTING_NUM_COLS;
    
    if (numCols < [self.gameInfo maxGridSize]) {
        gridSize = numCols + 1;
    }
    
    return gridSize;
}

- (void)toggleGridSizeAndContinueAnimation
{
    [self playSound:self.toggleGridSizeSound];
    
    // Core toggling here:
    
    [self.gameInfo toggleGridSize];
    
    [self resetBoard:[self.gameInfo curGridSize] numRows:[self.gameInfo curGridSize]];
    
    [self.gameInfo loadBoardFromInfo:self.board];
    
    [self loadBoardView];
    
    // After board reset/load from game info - keep cur cell, grid lines and blocked cells
    // in free cell background for animation purposes, fix this right away in upcoming animations
    
    self.curCell.backgroundColor = [The240GameViewController freeCellColor];
    for (UIView *gridLine in self.gridLines) {
        gridLine.backgroundColor = [The240GameViewController freeCellColor];
    }
    for (NSUInteger index = 0; index < [self.board numCells]; index++) {
        if (![self.board cellInIndexIsFree:index]) {
            [self.grid[index] setBackgroundColor:(__bridge CGColorRef)([The240GameViewController freeCellColor])];
        }
    }
    for (NSUInteger index = 0; index < [self.board numCells]; index++) {
        if (![self.board canFinishInIndex:index]) {
            [self.labelsGrid[index] setAlpha:0.0];
        }
    }
    
    // Continue with toggle grid animations
    
    [self animateFadeInGridLines];
}

- (void)animateFadeInGridLines
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         for (UIView *gridLine in self.gridLines) {
                             gridLine.backgroundColor = [The240GameViewController baseGameColor];
                         }
                         
                         // In case just toggled back to a board with blocked cells
                         
                         for (NSUInteger index = 0; index < [self.board numCells]; index++) {
                             if (![self.board cellInIndexIsFree:index] && index != self.board.curIndex) {
                                [self.grid[index] setBackgroundColor:(__bridge CGColorRef)([The240GameViewController blockedCellColor])];
                             }
                         }
                         
                         // In case game was just completed - need to restore frames
                         
                         for (UIView *frame in self.frames) {
                             frame.alpha = 1.0;
                         }
                         
                         // Fade-in cur cell
                         
                         self.curCell.backgroundColor = [The240GameViewController curCellColor];
                         self.curCell.alpha = 1.0;
                         
                         for (NSUInteger index = 0; index < [self.board numCells]; index++) {
                             if (![self.board canFinishInIndex:index] && index != self.board.curIndex && [self.board cellInIndexIsFree:index]) {
                                 [self.labelsGrid[index] setAlpha:LABELS_GRID_ALPHA];
                             }
                         }
                     }
                     completion:^(BOOL finished){
                         
                         // Make sure labels are still correct - compliment to condition inside animation
                         
                         for (NSUInteger index = 0; index < [self.board numCells]; index++) {
                             if (![self.board canFinishInIndex:index] && (index == self.board.curIndex || ![self.board cellInIndexIsFree:index])) {
                                 [self.labelsGrid[index] setAlpha:LABELS_GRID_ALPHA];
                             }
                         }
                         
                         [self animateFadeInGameScoreTitle];
                     }];
}

- (void)animateFadeInGameScoreTitle
{
    static BOOL first5x5GridToggling = YES;
    static BOOL first6x6GridToggling = YES;
    static BOOL first7x7GridToggling = YES;
    
    [self updateTitleFontSize];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self setAlphaToScoreLabelsAndButtons:1.0];
                         if (![self.board lost]) {
                             self.gameOverLabel.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished){
                         
                         // End of grid toggling animation
                         
                         if (first5x5GridToggling && [self.gameInfo maxGridSize] == 5 && [self.gameInfo curGridSize] == 5 && [self.gameInfo bestScore] == 0) {
                             [self animateFadeOutBoardShowHelpText:@[@"It is possible"] withDelay:1.5];
                             first5x5GridToggling = NO;
                         }
                         else if (first6x6GridToggling && [self.gameInfo maxGridSize] == 6 && [self.gameInfo curGridSize] == 6 && [self.gameInfo bestScore] == 0) {
                             [self animateFadeOutBoardShowHelpText:@[@"Go nuts"] withDelay:1.0];
                             first6x6GridToggling = NO;
                         }
                         else if (first7x7GridToggling && [self.gameInfo maxGridSize] == 7 && [self.gameInfo curGridSize] == 7 && [self.gameInfo bestScore] == 0) {
                             [self animateFadeOutBoardShowHelpText:@[@"It has come to this",
                                                                     @"You have reached an uncharted territory",
                                                                     @"The highlight of possible finishing cells doesn't work here",
                                                                     @"You're on your own",
                                                                     @"Good luck!"] withDelay:1.0];
                             first7x7GridToggling = NO;
                         }
                         else {
                             [self endMove];
                         }
                     }];
}

- (void)updateTitleFontSize
{
    if (!self.gameManager.singlesMode) {
        CGFloat titleFontSize = [self.board maxScore] > 1000 ? 42.0 : 54.0;
        self.maxScoreTitleLabel.font = [The240GameViewController gameFontWithSize:titleFontSize];
        self.scoreTitleLabel.font = [The240GameViewController gameFontWithSize:titleFontSize];
        
        CGFloat bestScoreFontSize = [self.board maxScore] > 1000 ? 16.0 : 20.0;
        self.bestScoreLabel.font = [The240GameViewController gameFontWithSize:bestScoreFontSize];
    }
}

#pragma mark Swipes and board move

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender
{
    if (self.moveSwipeAllowed && ![self.board lost]) { // the "&&" condition was added due to a bug when the board was lost but with available "X" cells - must avoid swipes
        [self boardMove:sender.direction];
    }
}

- (void)boardMove:(UISwipeGestureRecognizerDirection)direction
{
    NSUInteger movedFromIndex = self.board.curIndex;
    
    if ([self.board canMove:direction]) {
        
        self.moveSwipeAllowed = NO; // Is set to true in endMove method, called after a legal move animation completes
        
        [self.board move:direction];
        
        if (!self.gameManager.singlesMode) {
            [self.gameStatistics step];
            [self.gameInfo updateInfoFromBoard:self.board];
            [self updateScoreLabels];
        }
        
        // Notice: this includes advance and game completion animation
        [self animateMove:movedFromIndex isLevelWon:[self.board levelWon]];
    }
    else {
        [self playSound:self.cantMoveSound];
        return;
    }
    
    if ([self.board lost]) {
        self.moveSwipeAllowed = NO; // Retry button sets bit on again
        [self animateLost];
    }
}

#pragma mark Animations

- (void)animateMove:(NSUInteger)movedFromIndex isLevelWon:(BOOL)levelWon
{
    [self playSound:self.moveSound];
    
    self.menuButton.enabled = NO;
    self.retryButton.enabled = NO;
    
    [UIView animateWithDuration:0.1 * [self durationFactor]
                     animations:^{
                         self.curCell.center = [self indexToCenter:self.board.curIndex];
                     }
                     completion:^(BOOL finished){
                         [self animateMoveBlockPreviousCell:movedFromIndex isLevelWon:levelWon];
                         if (!levelWon) {
                             [self endMove];
                         }
                     }];
}

- (void)animateMoveBlockPreviousCell:(NSUInteger)movedFromIndex isLevelWon:(BOOL)levelWon
{
    [UIView animateWithDuration:0.35 * [self durationFactor]
                     animations:^{
                         [self.grid[movedFromIndex] setBackgroundColor: (__bridge CGColorRef)(self.recolorMode ?
                          [self getLevelColor] :
                          [The240GameViewController blockedCellColor])];
                         [self.labelsGrid[movedFromIndex] setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         if (levelWon) {
                             
                             if (self.gameManager.singlesMode) {
                                 
                                 BOOL curLevelGridIs4x4 = [self.singlesModeManager levelGridIs4x4];
                                 
                                 BOOL gameCompleted = [self.singlesModeManager advanceCheckGameCompleted];
                                 
                                 [self updateSingleModeNextPrevButtons];
                                 [self updateScoreLabels];
                                 
                                 if (gameCompleted) {
                                     [self gameCompletedSinglesMode];
                                 }
                                 else {
                                     NSUInteger curCellPrevIndex = self.board.curIndex;
                                     
                                     // This function also advances the singles mode to the next level.
                                     // In case level 16 (last level in 4x4 grid) is being completed AGAIN (after game was already completed),
                                     // this function also toggles the grid to 5x5 to get to the next level (unlike first game completion celebration)
                                     BOOL toggleGridIsPerformed = [self checkToggleGridSizeOnNextLevelSinglesMode:curLevelGridIs4x4];
                                     
                                     // Consider if grid was toggled - to avoid animation glitch
                                     [self animateAdvanceSinglesMode:toggleGridIsPerformed ? [self.singlesModeManager getLevelStartIndex] : curCellPrevIndex];
                                 }
                             }
                             else {
                             
                                 if ([self.board completedTheGame]) {
                                     [self gameCompleted];
                                 }
                                 else {
                                     [self animateAdvance];
                                 }
                                 // End move is called in advance / game completed animation methods
                             }
                         }
                     }];
}

- (CGFloat)durationFactor
{
    if (self.movie) {
        return 2.0;
    }
    if (self.debug) {
        return self.gameManager.singlesMode ? 1.0 : 0.2;
    }
    return 1.0;
}

- (void)endMove
{
    self.moveSwipeAllowed = YES;
    self.menuButton.enabled = YES;
    self.retryButton.enabled = YES;
    
    if (self.debug) {
        [self runDebugMovesStream];
    }
    else if (!self.gameManager.singlesMode) {
        [self.gameInfo save];
        [self.gameStatistics save];
    }
}

- (void)runDebugMovesStream
{
    if (![self.debugMovesStream length]) {
        // No more moves to run
        if (!self.gameManager.singlesMode) {
            [self.gameInfo save];
        }
        self.debug = NO;
        return;
    }
    
    UISwipeGestureRecognizerDirection direction = [The240GameViewController charToDirection:[self.debugMovesStream characterAtIndex:0]];
    self.debugMovesStream = (NSMutableString *)[self.debugMovesStream substringFromIndex:1];
    [self boardMove:direction];
}

#define LOST_ALPHA 0.5

- (void)animateLost
{
    [self.labelsGrid[self.board.curIndex] setHidden:YES];
    
    [self randomizeGameOverLabel];

    [UIView animateWithDuration:0.5
                          delay:0.7
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.curCell.alpha = LOST_ALPHA;
                         for (UIView *cell in self.grid) {
                             cell.alpha = LOST_ALPHA;
                         }
                         self.gameOverLabel.hidden = NO;
                         self.gameOverLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         [self playSound:self.lostSound];
                     }];
}

#define ADVANCE_LEVEL_BLINK_ANIMATION_DURATION 0.5
#define ADVANCE_LEVEL_BLINK_ANIMATION_DELAY 0.1
#define ADVANCE_LEVEL_BLINK_ANIMATION_TOTAL_DURATION (ADVANCE_LEVEL_BLINK_ANIMATION_DURATION * 2 + ADVANCE_LEVEL_BLINK_ANIMATION_DELAY)

- (void)animateAdvance
{
    [self playSound:self.levelAdvanceSound];
    
    [self.gameInfo advance:self.board];
    [self.gameStatistics advance:[self level] gridSize:[self.gameInfo curGridSize]];
    
    [UIView animateWithDuration:0.5 * [self durationFactor]
                     animations:^{
                         [self resetLevelCellsView];
                         // Emphasize the new "V" - to fade out soon in the completion animation
                         if ([self level] >= 2) {
                             NSUInteger newCantFinishIndexToShow = [self.gameInfo prevLevelStartIndex];
                             [self.labelsGrid[newCantFinishIndexToShow] setAlpha:1.0];
                         }
                         [self recolorIfNeeded];
                     }
                     completion:^(BOOL finished){
                         [self checkHelpTextAfterAdvance]; // This function calls endMove after done
                         
                         [UIView animateWithDuration:0.4 * [self durationFactor]
                                               delay:1.0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              for (UILabel* label in self.labelsGrid) {
                                                  label.alpha = LABELS_GRID_ALPHA;
                                              }
                                          }
                                          completion:^(BOOL finished){}];
                     }];
    
    [self animateBlinkAdvanceLabel:[self level] withDuration:ADVANCE_LEVEL_BLINK_ANIMATION_DURATION blinkFrames:YES];
}

- (void)animateAdvanceSinglesMode:(NSUInteger)curCellPrevIndex
{
    [self playSound:self.levelAdvanceSound];
    
    self.curCell.center = [self indexToCenter:self.board.curIndex];
    
    if (self.board.curIndex != curCellPrevIndex) {
        self.curCell.backgroundColor = (__bridge UIColor *)([self.grid[self.board.curIndex] backgroundColor]);
    }
    self.curCell.alpha = [self.grid[self.board.curIndex] alpha];
    
    [self.grid[curCellPrevIndex] setBackgroundColor:(__bridge CGColorRef)([The240GameViewController curCellColor])];

    [UIView animateWithDuration:0.5 * [self durationFactor]
                     animations:^{
                         [self resetLevelCellsView];
                         self.curCell.alpha = 1.0;
                         self.curCell.backgroundColor = [The240GameViewController curCellColor];
                         [self.labelsGrid[self.board.singlesModeFinishIndex] setHidden:YES];
                         [self.labelsGrid[self.board.singlesModeFinishIndex] setAlpha:0.0];
                     }
                     completion:^(BOOL finished){
                         [self checkHelpTextAfterSinglesAdvance];
                         
                         [UIView animateWithDuration:0.4 * [self durationFactor]
                                               delay:0.7
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              [self.labelsGrid[self.board.singlesModeFinishIndex] setHidden:NO];
                                              [self.labelsGrid[self.board.singlesModeFinishIndex] setAlpha:1.0];
                                          }
                                          completion:^(BOOL finished){}];
                     }];
    
    [self animateBlinkAdvanceLabel:self.singlesModeManager.curLevel withDuration:ADVANCE_LEVEL_BLINK_ANIMATION_DURATION blinkFrames:YES];
}

- (void)checkHelpTextAfterAdvance
{
    NSAssert(!self.gameManager.singlesMode, @"Can't call in singles mode");
    
    CGFloat helpTextDelay = ADVANCE_LEVEL_BLINK_ANIMATION_TOTAL_DURATION;
    
    if (![self gameIsStillPossible]) {
        [self.gameStatistics impossibleGame:[self level] gridSize:[self.gameInfo curGridSize]];
        [self animateFadeOutBoardShowHelpText:[self impossibleLevelHelpText] withDelay:helpTextDelay];
        return;
    }
    
    // 4x4 game
    static BOOL firstTime15 = YES;
    static BOOL firstTime30 = YES;
    static BOOL firstTime45 = YES;
    static BOOL firstTime120 = YES;
    static BOOL firstTime180 = YES;
    static BOOL firstTime210 = YES;
    static BOOL firstTime225 = YES;
    
    // 5x5 game
    static BOOL firstTime1205x5 = YES;
    static BOOL firstTime2405x5 = YES;
    static BOOL firstTime3605x5 = YES;
    static BOOL firstTime4805x5 = YES;
    static BOOL firstTime5765x5 = YES;
    
    NSUInteger bestScore = [self.gameInfo bestScore];
    
    // TODO: sharing options along the way?
    
    if (self.board.score != bestScore) {
        [self endMove]; // This means that best score is form a different session - advance text was already presented
    }
    else if (self.board.numCols == 4) {
        if (firstTime15 && bestScore == 15 && !self.debug) {
            [self animateFadeOutBoardShowHelpText:@[@"Welcome to\n240",
                                                    @"You've just completed the first level of the game",
                                                    @"Now, do it again",
                                                    @"You begin from the cell you finished in the last level",
                                                    @"You can go back\none level\nor restart the game\nfrom the menu"] withDelay:2.0]; // endMove is being called after help text is faded out
            firstTime15 = NO;
        }
        else if (firstTime30 && bestScore == 30 && !self.debug) {
            [self animateFadeOutBoardShowHelpText:@[@"Excellent!",
                                                    @"The goal is to\nsolve the board\n16 times",
                                                    @"Each time finishing in a different cell",
                                                    @"Notice the cell marked with\n\"✔︎\"",
                                                    @"That's where\nyou finished\nin the first level",
                                                    @"You cannot finish\nthere again for the rest of the game",
                                                    @"Good luck!"] withDelay:1.5];
            firstTime30 = NO;
        }
        else if (firstTime45 && bestScore == 45 && !self.debug) {
            [self animateFadeOutBoardShowHelpText:@[@"The starting cell determines which cells are possible to finish in",
                                                    @"Long-press on the board shows the possible finishing cells of this level",
                                                    @"Now go solve\nthe game"] withDelay:1.5];
            firstTime45 = NO;
        }
        else if (firstTime120 && bestScore == 120 && !self.debug) {
            [self animateFadeOutBoardShowHelpText:@[@"Halfway there!", @"Great job!"] withDelay:helpTextDelay];
            firstTime120 = NO;
        }
        else if (firstTime180 && bestScore == 180 && !self.debug) {
            [self animateFadeOutBoardShowHelpText:@[@"So many ✔︎'s...", @"You're getting closer"] withDelay:helpTextDelay];
            firstTime180 = NO;
        }
        else if (firstTime210 && bestScore == 210 && !self.debug) {
            [self animateFadeOutBoardShowHelpText:@[@"Almost there", @"The air gets thin"] withDelay:helpTextDelay];
            firstTime210 = NO;
        }
        else if (firstTime225 && bestScore == 225 && !self.debug) {
            [self animateFadeOutBoardShowHelpText:@[@"Only one to go", @"Good luck!"] withDelay:helpTextDelay];
            firstTime225 = NO;
        }
        else {
            [self endMove];
        }
    }
    else if (self.board.numCols == 5) {
        if (firstTime1205x5 && bestScore == 120 && !self.debug) {
            [self animateFadeOutBoardShowHelpText:@[@"Harder, isn't it?", @"One fifth of the way is behind you"] withDelay:helpTextDelay];
            firstTime1205x5 = NO;
        }
        else if (firstTime2405x5 && bestScore == 240 && !self.debug) {
            [self animateFadeOutBoardShowHelpText:@[@"Hey,\nit's 240 again!", @"That old game..."] withDelay:helpTextDelay];
            firstTime2405x5 = NO;
        }
        else if (firstTime3605x5 && bestScore == 360 && !self.debug) {
            [self animateFadeOutBoardShowHelpText:@[@"More than\nhalf way there", @"Not getting any easier"] withDelay:helpTextDelay];
            firstTime3605x5 = NO;
        }
        else if (firstTime4805x5 && bestScore == 480 && !self.debug) {
            [self animateFadeOutBoardShowHelpText:@[@"Twice the score of the 240 game", @"You're unstoppable!"] withDelay:helpTextDelay];
            firstTime4805x5 = NO;
        }
        else if (firstTime5765x5 && bestScore == 576 && !self.debug) {
            [self animateFadeOutBoardShowHelpText:@[@"You probably know what you're doing by now", @"Let's hope so", @"Good luck!"] withDelay:helpTextDelay];
            firstTime5765x5 = NO;
        }
        else {
            [self endMove];
        }
    }
    else {
        [self endMove]; // Don't call without else conditions: otherwise swipe will be allowed during help text
    }
}

- (void)checkHelpTextAfterSinglesAdvance
{
    NSAssert(self.gameManager.singlesMode, @"Must call in singles mode");
    
    CGFloat helpTextDelay = ADVANCE_LEVEL_BLINK_ANIMATION_TOTAL_DURATION;
    
    static BOOL firstTime5 = YES;
    static BOOL firstTime10 = YES;
    static BOOL firstTime14 = YES;
    static BOOL firstTime15 = YES;
    static BOOL firstTime20 = YES;
    static BOOL firstTime36 = YES;
    static BOOL firstTime44 = YES;
    static BOOL firstTime60 = YES;
    static BOOL firstTime71 = YES;
    
    // TODO: sharing options along the way?
    
    if (self.singlesModeManager.curLevel != self.singlesModeManager.maxLevel) {
        [self endMove]; // This means that this is not the first time that the level was completed - skip help text
    }
    else if (firstTime5 && self.singlesModeManager.curLevel == 5 && !self.debug) {
        [self animateFadeOutBoardShowHelpText:@[@"Great job!", @"Let's try different starting positions"] withDelay:helpTextDelay];
        firstTime5 = NO;
    }
    else if (firstTime10 && self.singlesModeManager.curLevel == 10 && !self.debug) {
        [self animateFadeOutBoardShowHelpText:@[@"Very nice", @"You're now ready for the difficult levels", @"Go get'em"] withDelay:helpTextDelay];
        firstTime10 = NO;
    }
    else if (firstTime14 && self.singlesModeManager.curLevel == 14 && !self.debug) {
        [self animateFadeOutBoardShowHelpText:@[@"OK", @"The last two levels are the hardest", @"Good luck"] withDelay:helpTextDelay];
        firstTime14 = NO;
    }
    else if (firstTime15 && self.singlesModeManager.curLevel == 15 && !self.debug) {
        [self animateFadeOutBoardShowHelpText:@[@"Free hint", @"Your first move this level should be UP", @"You're welcome"] withDelay:helpTextDelay];
        firstTime15 = NO;
    }
    else if (firstTime20 && self.singlesModeManager.curLevel == 20 && !self.debug) {
        [self animateFadeOutBoardShowHelpText:@[@"Harder, isn't it?", @"Many more\nto come"] withDelay:helpTextDelay];
        firstTime20 = NO;
    }
    else if (firstTime36 && self.singlesModeManager.curLevel == 36 && !self.debug) {
        [self animateFadeOutBoardShowHelpText:@[@"Wow,\nyou're really good", @"Halfway to complete the singles mode!"] withDelay:helpTextDelay];
        firstTime36 = NO;
    }
    else if (firstTime44 && self.singlesModeManager.curLevel == 44 && !self.debug) {
        [self animateFadeOutBoardShowHelpText:@[@"Excellent work!", @"From here it gets really difficult", @"Hang in there"] withDelay:helpTextDelay];
        firstTime44 = NO;
    }
    else if (firstTime60 && self.singlesModeManager.curLevel == 60 && !self.debug) {
        [self animateFadeOutBoardShowHelpText:@[@"The last level is really sweet", @"You should totally get there"] withDelay:helpTextDelay];
        firstTime60 = NO;
    }
    else if (firstTime71 && self.singlesModeManager.curLevel == 71 && !self.debug) {
        [self animateFadeOutBoardShowHelpText:@[@"So, it has come\nto this", @"The last level", @"You can do it", @"Good luck"] withDelay:helpTextDelay];
        firstTime60 = NO;
    }
    else {
        [self endMove];
    }
}

- (BOOL)gameIsStillPossible
{
    NSArray *endCells = [self.solver getEndCells:[self.gameInfo curGridSize] startIndex:[self.gameInfo levelStartIndex]];
    if ([endCells count] == 0) {
        return YES;
    }
    for (NSNumber *index in endCells) {
        if ([self.board canFinishInIndex:[index integerValue]]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)impossibleLevelHelpText
{
    NSMutableArray *helpTextArray = [NSMutableArray arrayWithArray:@[@"You have reached\na dead end",
                                                                     @"The possible finishing cells\nin this level are already marked"]];
    
    if (!self.longPressUsed) {
        [helpTextArray addObject:@"Long-press on the board shows the possible finishing cells of this level"];
    }
    
    [helpTextArray addObject:@"Go back one level or restart the game from the menu"];
    
    return helpTextArray;
}

- (NSUInteger)level
{
    return self.board.score / [self.board maxLevelScore];
}

- (void)animateBlinkAdvanceLabel:(NSUInteger)labelNumber withDuration:(NSTimeInterval)duration blinkFrames:(BOOL)blinkFrames
{
    self.bigLevelAdvanceLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)labelNumber];
    
    [UIView animateWithDuration:duration * [self durationFactor]
                          delay:ADVANCE_LEVEL_BLINK_ANIMATION_DELAY
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.bigLevelAdvanceLabel.hidden = NO;
                         self.bigLevelAdvanceLabel.alpha = 1.0;
                         if (blinkFrames) {
                             for (UIView *frame in self.frames) {
                                 frame.backgroundColor = [The240GameViewController advanceLevelLabelColor];
                             }
                         }
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:duration * [self durationFactor]
                                          animations:^{
                                              self.bigLevelAdvanceLabel.alpha = 0.0;
                                              if (blinkFrames) {
                                                  for (UIView *frame in self.frames) {
                                                      frame.backgroundColor = [The240GameViewController baseGameColor];
                                                  }
                                              }
                                          }
                                          completion:^(BOOL finished){
                                              self.bigLevelAdvanceLabel.hidden = YES;
                                          }];
                     }];
}

- (void)recolorIfNeeded
{
    if (!self.recolorMode) {
        return;
    }
    
    [self recolorIfNeeded:[self getLevelColor]];
}

- (void)recolorIfNeeded:(UIColor *)color;
{
    if (!self.recolorMode) {
        return;
    }
    
    [self setLabelsColor:@[self.scoreTitleLabel, self.slashTitleLabel, self.maxScoreTitleLabel,
                           self.bestScoreTextLabel, self.bestScoreLabel, self.helpTextLabel,
                           self.helpTextNextLabel, self.gameOverLabel] withColor:color];
    [self setButtonsColor:@[self.menuButton, self.retryButton, self.helpTextBackButton, self.helpTextSkipButton] withColor:color];
    [self setButtonsColor:self.menuButtons withColor:color];

    for (UIView *gridLine in self.gridLines) {
        gridLine.backgroundColor = color;
    }
    for (UIView *frame in self.frames) {
        frame.backgroundColor = color;
    }
    for (UILabel *label in self.labelsGrid) {
        label.textColor = color;
    }
}

- (void)animateRestart:(NSUInteger)curCellPrevIndex
{
    NSAssert([self.board isReset], @"Board must be reset when calling animate retry");
 
    [self playSound:self.retrySound];
    
    self.curCell.center = [self indexToCenter:self.board.curIndex];
    
    if (self.board.curIndex != curCellPrevIndex) {
        self.curCell.backgroundColor = (__bridge UIColor *)([self.grid[self.board.curIndex] backgroundColor]);
    }
    self.curCell.alpha = [self.grid[self.board.curIndex] alpha];
    
    [self.grid[curCellPrevIndex] setBackgroundColor:(__bridge CGColorRef)([The240GameViewController curCellColor])];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self resetLevelCellsView];
                         self.curCell.alpha = 1.0;
                         self.curCell.backgroundColor = [The240GameViewController curCellColor];
                         self.gameOverLabel.alpha = 0.0;
                         [self updateScoreLabels];
                         [self recolorIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.moveSwipeAllowed = YES;
                         self.gameOverLabel.hidden = YES;
                     }];
}

- (void)animateRetry:(NSUInteger)curCellPrevIndex withSound:(BOOL)withRetrySound
{
    if (withRetrySound) {
        [self playSound:self.retrySound];
    }
    
    self.curCell.center = [self indexToCenter:self.board.curIndex];
    
    if (self.board.curIndex != curCellPrevIndex) {
        self.curCell.backgroundColor = (__bridge UIColor *)([self.grid[self.board.curIndex] backgroundColor]);
    }
    self.curCell.alpha = [self.grid[self.board.curIndex] alpha];
    
    [self.grid[curCellPrevIndex] setBackgroundColor:(__bridge CGColorRef)([The240GameViewController curCellColor])];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self resetLevelCellsView];
                         self.curCell.alpha = 1.0;
                         self.curCell.backgroundColor = [The240GameViewController curCellColor];
                         self.gameOverLabel.alpha = 0.0;
                         [self updateScoreLabels];
                     }
                     completion:^(BOOL finished) {
                         self.moveSwipeAllowed = YES;
                         self.gameOverLabel.hidden = YES;
                     }];
}


// Unused - buggy
- (void)animateNumberReduceToZero:(NSUInteger) score
{
    static NSUInteger myScore = 0;
    
    myScore = score;
    
    if (myScore == 0) {
        return;
    }

    [UIView animateWithDuration:1
                          delay:1
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.bestScoreLabel.text = [NSString stringWithFormat:@"%lu", ((unsigned long)myScore)];
                     }
                     completion:^(BOOL finished) {
                         [self animateNumberReduceToZero:(myScore-1)];
                     }];
}

#pragma mark Help text

- (void)animateFadeOutBoard:(void (^)(BOOL finished))completionFunc withDelay:(NSTimeInterval) delay withAlpha:(float) alpha
{
    self.moveSwipeAllowed = NO;
    self.retryButton.enabled = NO;
    self.menuButton.enabled = NO;
    
    if (![self.board canFinishInIndex:self.board.curIndex]) {
        [self.labelsGrid[self.board.curIndex] setHidden:YES];
    }
    
    [UIView animateWithDuration:0.4
                          delay:delay
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         for (UIView *subview in self.boardView.subviews) {
                             subview.alpha = alpha;
                         }
                         [self setAlphaToScoreLabelsAndButtonsAndZeroAlphaForGameOverLabel:alpha];
                     }
                     completion:completionFunc];
}

- (void)animateFadeOutBoardShowHelpText:(NSArray *) helpTextArray withDelay:(NSTimeInterval) delay
{
    NSAssert([helpTextArray count] > 0, @"Cannot call fade-out board towards help text with and empty help text array");
    
    void (^completionFunc)(BOOL finished) = ^(BOOL finished){
        [self animateFadeInHelpTextArrayWithSkipButton:helpTextArray withDelay:0.0];
    };
    
    [self animateFadeOutBoard:completionFunc withDelay:delay withAlpha:0.2];
}

- (void)setHelpTextArrayAndNullIndex:(NSArray *)helpTextArray
{
    self.helpTextArray = helpTextArray;
    self.helpTextArrayIndex = 0;
}

- (NSUInteger)numberOfHelpTextsToShow
{
    return [self.helpTextArray count] - self.helpTextArrayIndex;
}

- (NSString *)getNextHelpTextAndAdvanceIndex
{
    NSAssert([self numberOfHelpTextsToShow] > 0, @"Help text array and index don't match - invalid logic");
    NSString *helpText = self.helpTextArray[self.helpTextArrayIndex];
    self.helpTextArrayIndex++;
    return helpText;
}

- (void)animateFadeInHelpTextArrayWithSkipButton:(NSArray *)helpTextArray withDelay:(NSTimeInterval) delay
{
    [self animateFadeInHelpTextArray:helpTextArray withDelay:delay withSkipButton:YES];
}

- (void)animateFadeInHelpTextArrayNoSkipButton:(NSArray *)helpTextArray withDelay:(NSTimeInterval) delay
{
    [self animateFadeInHelpTextArray:helpTextArray withDelay:delay withSkipButton:NO];
}

- (void)animateFadeInHelpTextArray:(NSArray *)helpTextArray withDelay:(NSTimeInterval) delay withSkipButton:(BOOL)withSkipButton
{
    NSAssert([helpTextArray count] > 0, @"Cannot call animate fade-in help text with an empty array");
    
    [self setHelpTextArrayAndNullIndex:helpTextArray];
    
    if (withSkipButton) {
        [self animateFadeInHelpTextSkipButton:delay];
    }
    
    [self animateFadeInHelpText:[self getNextHelpTextAndAdvanceIndex] withDelay:delay];
}

- (void)animateFadeInHelpTextSkipButton:(NSTimeInterval) delay
{
    self.helpTextSkipButton.hidden = NO;
    self.helpTextSkipButton.alpha = 0.0;
    
    [self.boardView bringSubviewToFront:self.helpTextSkipButton];
    
    [UIView animateWithDuration:0.4
                          delay:delay
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.helpTextSkipButton.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {}];
}

- (void)animateFadeInHelpText:(NSString *) helpText withDelay:(NSTimeInterval) delay
{
    self.helpTextLabel.hidden = NO;
    self.helpTextLabel.alpha = 0.0;
    self.helpTextLabel.text = helpText;
    
    BOOL needToShowNextLabel = self.helpTextNextLabel.hidden && [self numberOfHelpTextsToShow] > 0;
    BOOL needToShowBackButton = self.helpTextBackButton.hidden && self.helpTextArrayIndex > 1;
    
    if (needToShowNextLabel) {
        
        // First time help text appears (and there's more than one text) - need to show next label
        
        self.helpTextNextLabel.hidden = NO;
        self.helpTextNextLabel.alpha = 0.0;
    }
    
    if (needToShowBackButton) {
        
        // First time back button is necessary (more than one help text, and we already advanced one help text)
        
        self.helpTextBackButton.hidden = NO;
        self.helpTextBackButton.alpha = 0.0;
    }
    else if (self.helpTextArrayIndex <= 1) {
        [self hideAndDisableButtons:@[self.helpTextBackButton]];
    }
    
    [UIView animateWithDuration:0.4
                          delay:delay
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.helpTextLabel.alpha = 1.0;
                         
                         if (needToShowNextLabel) {
                             self.helpTextNextLabel.alpha = 1.0;
                         }
                         if (needToShowBackButton) {
                             self.helpTextBackButton.alpha = 1.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         self.helpTextIsOn = YES;
                         
                         if (!self.helpTextBackButton.hidden) {
                             self.helpTextBackButton.enabled = YES;
                         }
                         
                         if (!self.helpTextSkipButton.hidden) { // hidden is the right condition, not enabled, since it's enabled/disabled in every help text fade-in/fade-out...
                             self.helpTextSkipButton.enabled = YES;
                         }
                     }];
}

- (void)animateFadeInHelpText:(NSString *) helpText
{
    [self animateFadeInHelpText:helpText withDelay:0.0];
}

- (void)animateFadeOutHelpText
{
    self.helpTextIsOn = NO;
    self.helpTextSkipButton.enabled = NO;
    self.helpTextBackButton.enabled = NO;
    
    if ([self numberOfHelpTextsToShow] > 0) {
        [UIView animateWithDuration:0.4
                         animations:^{
                             self.helpTextLabel.alpha = 0.0;
                             if ([self numberOfHelpTextsToShow] == 1) {
                                 self.helpTextNextLabel.alpha = 0.0;
                             }
                             if (self.helpTextArrayIndex == 0) {
                                 self.helpTextBackButton.alpha = 0.0;
                             }
                         }
                         completion:^(BOOL finished) {
                             if ([self numberOfHelpTextsToShow] == 1) {
                                 self.helpTextNextLabel.hidden = YES;
                             }
                             [self animateFadeInHelpText:[self getNextHelpTextAndAdvanceIndex]];
                         }];
    }
    else {
        [UIView animateWithDuration:0.4
                         animations:^{
                             self.helpTextLabel.alpha = 0.0;
                             self.helpTextNextLabel.alpha = 0.0;
                             self.helpTextSkipButton.alpha = 0.0;
                             self.helpTextBackButton.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             self.helpTextLabel.hidden = YES;
                             self.helpTextNextLabel.hidden = YES;
                             [self hideAndDisableButtons:@[self.helpTextSkipButton, self.helpTextBackButton]];
                         }];
        
        if (self.menuIsOn) {
            [self animateFadeInMenu];
        }
        else if (self.gameIsCompleted) {
            [self animateFadeOutTextGameIsCompleted];
        }
        else {
            [self animateFadeInBoardContinueGame];
        }
    }
}

- (void)animateFadeInBoardContinueGame
{
    static BOOL gameStart = YES;
    static BOOL singlesGameStart = YES;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         for (UIView *subview in self.boardView.subviews) {
                             subview.alpha = 1.0;
                         }
                         
                         // Bug fix here: 240 game completed => menu => home => 240 (without this line the cur cell is white)
                         self.curCell.backgroundColor = [The240GameViewController curCellColor];
                         
                         // Make sure to update the labels alpha as well (being nulled if coming back from menu)
                         
                         if (self.gameManager.singlesMode) {
                             [self.labelsGrid[self.board.singlesModeFinishIndex] setHidden:NO];
                             [self.labelsGrid[self.board.singlesModeFinishIndex] setAlpha:1.0];
                         }
                         else {
                             for (NSUInteger index = 0; index < [self.board numCells]; index++) {
                                 if (index == self.board.curIndex) {
                                     continue;
                                 }
                                 if (![self.board canFinishInIndex:index]) {
                                     [self.labelsGrid[index] setHidden:NO];
                                     [self.labelsGrid[index] setAlpha:LABELS_GRID_ALPHA];
                                 }
                             }
                         }
                         
                         [self setAlphaToScoreLabelsAndButtonsAndZeroAlphaForGameOverLabel:1.0];
                         
                         // If board is lost - restore lost board view
                         
                         [self restoreLostBoardViewIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                         // Undo preparations of fade-out board
                         
                         if (![self.board canFinishInIndex:self.board.curIndex]) {
                             [self.labelsGrid[self.board.curIndex] setHidden:NO];
                             [self.labelsGrid[self.board.curIndex] setAlpha:LABELS_GRID_ALPHA];
                         }
                         
                         // 240 game start text here:
                         if (gameStart && !self.gameManager.singlesMode && [self.gameInfo bestScore] == 0 && [self.gameInfo curGridSize] == STARTING_NUM_COLS) {
                             [self animateFadeOutBoardShowHelpText:@[@"Slide the orange square around the board to\nvisit every cell"] withDelay:2.0];
                             gameStart = NO;
                         }
                         else if (singlesGameStart && self.gameManager.singlesMode && self.singlesModeManager.maxLevel == 0) {
                             [self animateFadeOutBoardShowHelpText:@[@"Slide the orange square around the board to\nvisit every cell",
                                                                     @"Every visited cell will be blocked",
                                                                     @"Finish in the marked cell"] withDelay:2.0];
                             singlesGameStart = NO;
                         }
                         else {
                             [self endMove];
                         }
                     }];
}

- (void)restoreLostBoardViewIfNeeded
{
    if ([self.board lost]) {
        self.curCell.alpha = LOST_ALPHA;
        for (UIView *cell in self.grid) {
            cell.alpha = LOST_ALPHA;
        }
        self.gameOverLabel.hidden = NO;
        self.gameOverLabel.alpha = 1.0;
    }
}

- (void)animateFadeInMenu
{
    [self showAndEnableButtons:self.menuButtons]; // Doesn't change the alpha = 0.0
    
    // Not sure why but this is needed. Otherwise share/rate buttons appear later (after first call of menu). Maybe bug - but this fixes it.
    for (UIButton *button in self.menuButtons) {
        button.alpha = 0.0;
    }

    [self showAndEnableButtons:@[self.homeButton]];
    self.homeButton.alpha = 0.0;
    
    // Notice it is very similar to animateFadeOutBoard - but without fading out the frame
    
    self.moveSwipeAllowed = NO;
    self.retryButton.enabled = NO;
    self.menuButton.enabled = NO;
    
    if (![self.board canFinishInIndex:self.board.curIndex]) {
        [self.labelsGrid[self.board.curIndex] setHidden:YES];
    }
    
    [UIView animateWithDuration:0.4
                     animations:^{

                         // Fade-out all the board except the frame
                         
                         self.curCell.alpha = 0.0;
                         
                         for (NSUInteger index = 0; index < [self.board numCells]; index++) {
                             [self.grid[index] setAlpha:0.0];
                             [self.labelsGrid[index] setAlpha:0.0];
                         }
                         
                         for (UIView *gridLine in self.gridLines) {
                             gridLine.alpha = 0.0;
                         }
                         
                         [self setAlphaToScoreLabelsAndButtonsAndZeroAlphaForGameOverLabel:0.0];
                         
                         for (UIButton *button in self.gameCompletionButtons) {
                             button.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         
                         [self hideAndDisableButtons:self.gameCompletionButtons];
                         
                         [UIView animateWithDuration:0.4
                                          animations:^{
                                              // Fade-in menu buttons
                                              
                                              for (UIButton *button in self.menuButtons) {
                                                  if (self.gameManager.singlesMode && (self.singlesModeNextButton == button ||
                                                                                       self.singlesModePrevButton == button ||
                                                                                       self.singlesModeLastButton == button ||
                                                                                       self.singlesModeFirstButton == button)) {
                                                      continue;
                                                  }
                                                  button.alpha = 1.0;
                                              }
                                              self.homeButton.alpha = 1.0;
                                              
                                              if (self.gameManager.singlesMode) {
                                                  [self updateSingleModeNextPrevButtons];
                                              }
                                              
                                              // In case it's after game completion - restore background for board frame
                                              
                                              for (UIView *frame in self.frames) {
                                                  frame.alpha = 1.0;
                                              }
                                          }];
                     }];
}

#pragma mark Tests

+ (UISwipeGestureRecognizerDirection)charToDirection:(char)c
{
    switch (c) {
        case 'R': return UISwipeGestureRecognizerDirectionRight;
        case 'D': return UISwipeGestureRecognizerDirectionDown;
        case 'L': return UISwipeGestureRecognizerDirectionLeft;
        case 'U': return UISwipeGestureRecognizerDirectionUp;
    }
    NSAssert(0, @"Invalid direction character");
    return UISwipeGestureRecognizerDirectionRight;
}

- (void)boardMoveDirectionsStream:(NSString *)movesStream
{
    // This will make the endMove method to call the next for move in moves stream
    self.debug = YES;

    UISwipeGestureRecognizerDirection direction = [The240GameViewController charToDirection:[movesStream characterAtIndex:0]];
    
    self.debugMovesStream = (NSMutableString *)[movesStream substringFromIndex:1];
    
    [self boardMove:direction];
}

- (NSString *)solutionSingles
{
    return @"RULRLDRURDLURDRRULRDLUDLURLRDRRULDRULRULDUDRDRUDLUDRLURDUDLDRULDURLURDLURLULURLRDRULDRLRULLURDLULDLURLRDRLDRLRURDULURDRDLDRLRUDRUDLURDRDLUDURLURLDUDRDULDURULDRULRLURRULDUDRULURDUDLLURLRDRULDRLURDLURLRDURDULRLULRULRLDULDRULDULUDRUDLRULDUDRD"; // R
}

- (NSString *)solutionSingles5x5
{
    return @"RULRLDURDLUDRLDRDLUDURDLRULRLDURDLUDRLDRDLUDUDRURULRDLRULDRULDURLURDLUDRRULRLRDLUDLUDRULRDULRDRLRULRLRDRULRLDULDRUDLRDLRRULRLRDRURDULDURLRULRDRLRULDUDURDLUDURLURDLUDRUDRULDURDULRULRDRULRLUDRURRULRDLUDRLURDLDURUDRLULRRULDURLRULRDRURDLRLRUDLRRLRURDUDLDURUDLDRUDULRULRULRLRDULDUDRLUDRULDULDRRULRDURDULDURLURDULRDRLDRULRDURDULRDLDRURDULRDURRULRLDLURDLURLURDUDLRUDURULRLDULDUDRLURLUDRLDUDLRULRLDULDUDRUDLRDULRUDURLRULDUDRDULUDRDULUDURLURRULRDULDUDRUDLDURLULDRDRRDLRLRULDUDRLUDRULDULDURLDRULRLDLURLRDLRUDUDRLDRLDRULRDLRULDLURLRLDRULRDRDLRLRULDUDRLUDRULDLURDLRDLRLRULDUDRLUDRULDLUDRURULDURDLDRDRLRULDURDULUDULRDRLRUDRUDULDUDRUDRLURURLDLRLUDLUDURDUDLUDLURDURLDLRLUDLUDURDULURLDRDRRULRLRDRUDRUDLURLDURLDLRRULDURDULRUDLURDRULRUDLDRULDRUDRULDURLURULDUDRDURDLUDUDRLUDRULRDLRURDULDURLDLRLUDLUDURLDRDULULDRRUDULDUDRDRLRULRLDURLDRDRULDRUDLRUDLRULDUDURDURDRLURLRDURDLUDURLDURLRDLDRUDLURLDULDRLDRDLUDUDRURRLULDURULRDULRDULRDRLRURRULRDLRUDLRUDLURLRLDRLDRRULDURLURLDRUDRULDRLURLULURLRLDURLDURDULRLRULRULLURLDLURDUDLDRUDUDLRLURURLRURDUDLDURLRULDRDLRULUULDURULDRLUDRULRULRDULDLLURDULRULRDULDLURLRLDRLDLUDUDRDLUDLUDURULDULDRDRRULDURDULRDULRULDUDURURURLULRLDULDUDRUDLDRLUDRURLRUDLUDURULRDRULURLDURDRULDRUDLUDRLURULDULDURDRDDLUDURDULRLURLRDLRDUDRLDDLUDUDRLURDLRULDUDURDURDURDUDLDLRLULDRULDRLRLURULUDURDUDLDLRLUDUDRLUDRURRULDUDRDRLRULRDLRURLRDURRULDRLUDLUDRURLURDLURLU"; // D
}

- (NSString *)solution240
{
    return @"RUDLUDRLURDUDLDLURLRDURDULRLULURDUDLRDLRUDURURDLRLUDLUDRLRDRDLRURDLURDURDLRDLUDURLURLDUDRDLUDRUDLRULDUDRDRULDRURDRULRLDLDRULDRDLDRUDULULDRULDLULDRLRURULDUDRDLRUDLUDRURDUDLRDLRUDULURLRDRULRLDLURLRRDLRLUDLUDRLRURLRDRUDLDRUDRULRLURLRDURDULRLD"; //L
}

- (NSString *)solution600
{
    return @"RLURLRDURDLUDURLDURLRDLDRLUDRUDULURLDLURULRDULDLURDLRLRULDRLRUDRULDRLURLLDRUDULULRLDRLURLDLRLUDLUDRLURLRDRUDLDRURDULRDLDLURLDLURDUDLDRUDUDLRLURURLDURDUDLDRLULDRDLRUDLULURLDLUDRDLRUDLRUDLURLRDRUDLRULRLDLUDRDLULDURLDRDURDULURDLRUDLURLURLDURDRDLRLRURDLRDLRLULDRLDRURUDRUDLDRULRDULDRLDRLUDRURULRDRULDURLDRUDRUDLRULRURLRDRUDULUDRLRDLURULDURUDRULRLRDRLDURDLDRULDRDRLRUDULDUDRDRLRUDUDLRUDLULRLRLDRUDULURDUDLDRURDULDDLUDUDRLURDLRULDUDURDURDULRLRDULRDLUDRLURULDULDRRDLRLRUDLURDULDRLRLURLURLRLDRULDURDLRDLUDLUDRLURRULRLDLUDURLDRDLRUDLUDULULDUDRLDRLURLDURDLRDLUDLRUDLDUDRLDRLRULRLDRDLUDRULRLDRLRURUDULRLRDULRDL"; //D
}

- (NSString *)solution1260
{
    return @"RULRLRLDRURDULURLDURDLURLRLUDRDUDLRRULRLRLDRULDRLUDLUDRURLURDLRUDRULDRRULRLRLDRULDRULDRLDRDLULURDLRULDLRDRULRLRLDRULDURURLRDURDRULURDURULDLDRULRLRLDRULRLRDRURDLURLDLURURDLULUDRULRLRLDRLRDRULDURLULDRDRULDLRUDRLURULDRULRLDRLRULURDURDLDRLUDRLRUDLRLRULRLRLDRUDULUDRDUDLDRUDURDULUDURURRULRLRLDRULRDLULRLDURLDRULDURURLRDRRULRLDRLRLULDRULRDRLRURDLDUDRUDURLRRULRLRLDURLRDRUDLDRULDURLDRUDLRLDRDRULRLRLDURLRDUDRUDLDRULDRLRDLRURLRDRULRLRLDRLRURDULRDULRULRLDURLDULDLDRULRLRLDRULRLDULDRUDLRDLURDULUDURLRRULRLRLDRULURLRLRDRULDLURLRLRUDLULRRULRLRLDLURLRLRDRLULRDLUDRDLULRLDLDRULRLRLDRLURDUDLDURUDULRDULDRUDULULRULRLRLDRULRDURDLDRURLRDULRDRLULRLDRULDRLRULRDLUDULDUDRLUDRLDRDLUDURURULRLRLDRULRULRDRURDLDRURDRLUDLRULDURULRLRLDLRULUDURULDRULRDULDURLDRLDRULRLRLDRURDUDLRDLDRULDRLDURDULUDURURULRLRLDULRDLURLDLURLRUDLRDRULURDRDRULRLRLDRULDRURDRLRURDULRDLRULRDLDLRDLRURDULRDLRDLRULRDLURLRLDURLUDULRRULDURURLRDLRURLURDRUDLRUDLRDLRULULRULRDRULRLDLURLRLDRUDURLDLRDLUDULRURLRLDRLURDLDRUDRLUDLUDURDUDURURLRDRULRLRLDRLRURDLURDLDRUDRUDLRURLRDRDRULRLDULDURULURDRLUDLRUDRLULRLDUDLULRULDURLURDRULDRLURLDULDRLRUDRUDLULURLRDRULURDRULRDULDUDRLUDRLDRLUDRUDRULDRUDLURLDULDRDULURULRDRULUDURLURURDULRDURDLUDRLRLURDLRLURLRUDULRULULRLRDRULRDRUDLRULRDUDLRDLRUDUDRUDURULRLDLUDRDLULDRDLUDLURDLURDRLRURUDR"; //U
}

- (void)test
{
//    NSString *movesStream = @"RULDRULRULDUDRD";//RUDULURDLDR";
    
//    [self boardMoveDirectionsStream:@"UDRL"];return;
//    [self boardMoveDirectionsStream:[[self solution240] substringToIndex:33]];return; //U
//    [self boardMoveDirectionsStream:[[self solution240] substringToIndex:122]];return; //UL
    
//    [self boardMoveDirectionsStream:@"UDRLRD"];return; // For lost scenario
    
    if (self.gameManager.singlesMode) {
        if (self.board.numCols == STARTING_NUM_COLS) {
            [self boardMoveDirectionsStream:[self solutionSingles]];
        }
        else {
            NSRange r;
            r.location = (self.singlesModeManager.curLevel - [self.singlesModeManager numLevels4x4]) * 24;
            r.length = self.singlesModeManager.curLevel == [self.singlesModeManager numLevels] - 1 ? 23 : 24;
            [self boardMoveDirectionsStream:[[self solutionSingles5x5] substringWithRange:r]];
        }
    }
    else if ([self.gameInfo curGridSize] == 4) {
        [self boardMoveDirectionsStream:[self solution240]];
    }
    else if ([self.gameInfo curGridSize] == 5) {
        [self boardMoveDirectionsStream:[self solution600]];
    }
    else if ([self.gameInfo curGridSize] == 6) {
        [self boardMoveDirectionsStream:[self solution1260]];
    }
    else {
        [self endMove];
    }
}

#pragma mark Buttons

- (IBAction)retryButton:(UIButton *)sender
{
    [self retry];
}

- (void)playMovieSound
{
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/game3.mp3", [[NSBundle mainBundle] resourcePath]]; // Maybe must be in m4a format?
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSError *err = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&err];
    if (err) {
        NSLog(@"Error description: %@", [err description]);
    }
    [player prepareToPlay];
    player.numberOfLoops = -1;
    [player play];
}

- (IBAction)menu:(UIButton *)sender
{
    if (self.movie) {
//        AudioServicesPlaySystemSound(self.movieSound);
        [self playMovieSound];
        [self boardMoveDirectionsStream:[self solution240]];
        return;
    }
    
    [self playSound:self.menuInSound];
    
    [Flurry logEvent:@"Menu" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%lu", (unsigned long)[self level]], @"Level",
                                             [NSString stringWithFormat:@"%lu", (unsigned long)[self.gameInfo curGridSize]], @"Grid Size",
                                             nil]];
    
    self.menuIsOn = YES;
    
    [self animateFadeInMenu];
}

- (IBAction)home:(UIButton *)sender
{
    [self playSound:self.menuInSound];
    
    [Flurry logEvent:@"Home" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%lu", (unsigned long)[self level]], @"Level",
                                             [NSString stringWithFormat:@"%lu", (unsigned long)[self.gameInfo curGridSize]], @"Grid Size",
                                             nil]];
    
    self.menuIsOn = YES;
    
    [self showAndEnableButtons:self.homeButtons]; // Doesn't change the alpha = 0.0
    self.homeNewLabel.alpha = 0.0;
    self.homeNewLabel.hidden = NO;
    
    // Not sure why but this is needed. Otherwise buttons appear later (after first call of home). Maybe bug - but this fixes it.
    for (UIButton *button in self.homeButtons) {
        button.alpha = 0.0;
    }
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         for (UIButton *button in self.menuButtons) {
                             button.alpha = 0.0;
                         }
                         self.homeButton.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         [self hideAndDisableMenuButtons];
                         
                         [self hideAndDisableButtons:self.gameCompletionButtons]; // Needed?
                         
                         [UIView animateWithDuration:0.4
                                          animations:^{
                                              // Fade-in home buttons
                                              
                                              for (UIButton *button in self.homeButtons) {
                                                  button.alpha = 1.0;
                                              }
                                              self.homeNewLabel.alpha = 1.0;
                                          }];
                     }];
}

- (IBAction)play240FromHome:(UIButton *)sender
{
    [self playSound:self.menuInSound];
    
    if (self.gameManager.singlesMode) {
        [self start240];
    }
    
    [self animateFadeOutHomeContinueGame];
}

- (IBAction)play240FromSingleModeCompletion:(UIButton *)sender
{
    NSAssert(self.gameManager.singlesMode, @"Must call from singles mode");
    
    [self playSound:self.toggleGridSizeSound];
    
    [self start240];

    [UIView animateWithDuration:0.4
                     animations:^{
                         for (UIButton *button in self.gameCompletionButtons) {
                             button.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         [self hideAndDisableButtons:self.gameCompletionButtons];
                         [self animateFadeInBoardContinueGame];
                     }];

}

- (void)start240
{
    self.gameManager.singlesMode = NO;
    [self.gameManager save];
    
    self.gameIsCompleted = NO;
    
    if (![self loadFromGameInfo]) {
        [self resetBoard:STARTING_NUM_COLS numRows:STARTING_NUM_ROWS];
    }
    
    if ([self.gameInfo maxGridSize] == STARTING_NUM_COLS && [self.gameInfo bestScore] < 240) {
        [self setBasicMenuButtons];
    }
    else {
        [self setAdvancedMenuButtons];
    }
    
    [self.board setStandardMode];
    [self setStandardModeLabels];
    [self updateScoreLabels];
}

- (IBAction)playSinglesModeFromHome:(UIButton *)sender
{
    [self playSound:self.menuInSound];
    
    if (!self.gameManager.singlesMode) {
        self.gameManager.singlesMode = YES;
        [self.gameManager save];
        
        [self startSinglesMode];
    }
    
    [self animateFadeOutHomeContinueGame];
}

- (void)animateFadeOutHomeContinueGame
{
    self.menuIsOn = NO;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         for (UIButton *button in self.homeButtons) {
                             button.alpha = 0.0;
                         }
                         self.homeNewLabel.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self hideAndDisableButtons:self.homeButtons];
                         self.homeNewLabel.hidden = YES;
                         [self animateFadeInBoardContinueGame];
                     }];
}

- (void)restart
{
    self.gameIsCompleted = NO;
    self.moveSwipeAllowed = NO;
    
    NSUInteger curCellPrevIndex = self.board.curIndex;
    [self.gameInfo restart:self.board];
    [self animateRestart:curCellPrevIndex]; // Also turns on the moveSwipeAllowed bit
}

- (void)retry
{
    [self.gameStatistics retry:[self level] gridSize:[self.gameInfo curGridSize]];
    [self retry:YES];
}

- (void)retryNoSound
{
    // Don't report retry here because this is used only in go back scenario - where "go back" is reported instead.
    [self retry:NO];
}

- (void)retry:(BOOL)withRetrySound
{
    static BOOL firstTime = YES;
    
    if (firstTime) {
//        [self rate:nil];return;
//        firstTime = NO;
//        [self test]; return;
//        [self gameCompleted];return;
//        [self animateLost];return;
//        [self.singlesModeManager advanceCheckGameCompleted];[self updateSingleModeNextPrevButtons];[self updateScoreLabels];[self animateAdvanceSinglesMode:self.board.curIndex];return;
    }
    
    if (self.gameIsCompleted) {
        
        self.gameIsCompleted = NO;
        
        [self animateFadeOutGameCompletionButtons];
        
        if (self.gameManager.singlesMode) {
            [self.singlesModeManager prevLevel];
            [self loadBoardSinglesLevel];
        }
        else {
            [self restart];
            return;
        }
    }
    
    self.moveSwipeAllowed = NO;
    NSUInteger curCellPrevIndex = self.board.curIndex;
    
    if (self.gameManager.singlesMode) {
        [self.board resetLevel:[self.singlesModeManager getLevelStartIndex]];
        [self.singlesModeManager retry];
    }
    else {
        [self.gameInfo resetLevel:self.board];
    }
    
    [self animateRetry:curCellPrevIndex withSound:withRetrySound]; // Also turns on the moveSwipeAllowed bit
}

- (IBAction)toggleGridSizeButton:(UIButton *)sender
{
    self.gameIsCompleted = NO;
    
    self.menuIsOn = NO;
    self.moveSwipeAllowed = NO;
    
    NSUInteger nextGridSize = [self getGridSizeAfterToggle:self.board.numCols];
    [self.gameStatistics toggleGridSize:nextGridSize];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         for (UIButton *button in self.menuButtons) {
                             button.alpha = 0.0;
                         }
                         self.homeButton.alpha = 0.0;

                         for (UIButton *button in self.gameCompletionButtons) {
                             button.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         
                         [self hideAndDisableMenuButtons];
                         [self hideAndDisableButtons:self.gameCompletionButtons];
                         
                         NSUInteger nextNextGridSize = [self getGridSizeAfterToggle:nextGridSize];
                         [self updateToggleGridSizeMenuButtonTitle:nextNextGridSize];

                         [self toggleGridSizeAndContinueAnimation]; // Includes actual toggling function
                     }];
}

- (IBAction)moreSinglesGameCompletionButton:(UIButton *)sender
{
    [self playSound:self.toggleGridSizeSound];
    
    self.gameIsCompleted = NO;
    
    self.menuIsOn = NO;
    self.moveSwipeAllowed = NO;

    NSAssert(self.board.numCols == STARTING_NUM_COLS, @"Singles mode completion must mean 4x4 board");
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         for (UIButton *button in self.menuButtons) {
                             button.alpha = 0.0;
                         }
                         self.homeButton.alpha = 0.0;

                         for (UIButton *button in self.gameCompletionButtons) {
                             button.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         
                         [self hideAndDisableMenuButtons];
                         [self hideAndDisableButtons:self.gameCompletionButtons];
                         
                         [self singlesNextLevel5x5];
                     }];

}

- (void)singlesNextLevel5x5
{
    [self resetBoard:STARTING_NUM_COLS+1 numRows:STARTING_NUM_ROWS+1];
    [self loadBoardSinglesLevel];
    [self loadBoardView];
    
    // After board reset/load from game info - keep cur cell, grid lines and blocked cells
    // in free cell background for animation purposes, fix this right away in upcoming animations
    
    self.curCell.backgroundColor = [The240GameViewController freeCellColor];
    for (UIView *gridLine in self.gridLines) {
        gridLine.backgroundColor = [The240GameViewController freeCellColor];
    }
    
    // Continue with toggle grid animations
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         for (UIView *gridLine in self.gridLines) {
                             gridLine.backgroundColor = [The240GameViewController baseGameColor];
                         }
                         for (UIView *frame in self.frames) {
                             frame.alpha = 1.0;
                         }
                         
                         self.curCell.backgroundColor = [The240GameViewController curCellColor];
                         self.curCell.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              [self setAlphaToScoreLabelsAndButtons:1.0];
                                          }
                                          completion:^(BOOL finished) {
                                              [self endMove];
                                          }];
                     }];
}

- (IBAction)tapBoard:(UITapGestureRecognizer *)sender
{
    if (!self.howToPlayTextView.hidden) {
        NSLog(@"Logic error - tap should call tapOnHowToPlayText method, not this gesture");
        return;
    }
    if (self.helpTextIsOn && self.helpTextTapAllowed) {
        [self animateFadeOutHelpText];
    }
    else if ([self.board lost] && !self.menuIsOn) {
        [self retry];
    }
    
    // Notice potential bug here: if help text appears in case of a lost board, not inside the menu mode. No scenrio of this in the game, just potential bug.
}

- (IBAction)tapOnHowToPlayText:(UITapGestureRecognizer *)sender
{
    if (!self.howToPlayTextView.hidden) {
        [self animateFadeOutHowToPlayText];
    }
    else {
        NSLog(@"Unclear behavior by gesture - this gesture is linked to the how to play text view");
    }
}

- (IBAction)skipHelpText:(UIButton *)sender
{
    [self setHelpTextArrayAndNullIndex:@[]];
    [self animateFadeOutHelpText];
}

- (IBAction)backHelpText:(UIButton *)sender
{
    NSAssert(self.helpTextArrayIndex >= 2, @"Invalid logic - there can't be any help text to go back to");
    self.helpTextArrayIndex -= 2;
    [self animateFadeOutHelpText];
}

- (IBAction)boardLongPressShowPossibleEndCells:(UILongPressGestureRecognizer *)sender
{
    if (self.menuIsOn || self.helpTextIsOn || self.gameIsCompleted || self.gameManager.singlesMode) {
        return;
    }
    
    NSArray *endCells = [self.solver getEndCells:[self.gameInfo curGridSize] startIndex:[self.gameInfo levelStartIndex]];
    
    if ([endCells count] > 0) {
        
        if (sender.state == UIGestureRecognizerStateBegan) {

            self.menuButton.enabled = NO;
            self.retryButton.enabled = NO;
            
            [UIView animateWithDuration:0.4
                             animations:^{
                                 for (NSNumber *index in endCells) {
                                     NSUInteger i = [index integerValue];
                                     if ([self.board cellInIndexIsFree:i]) {
                                         [self.grid[i] setBackgroundColor:(__bridge CGColorRef)([The240GameViewController endCellColor])];
                                         if (![self.board canFinishInIndex:i]) {
                                             [self.grid[i] setAlpha:0.5];
                                         }
                                     }
                                 }
                             }];
        }
        
        if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
            
            self.menuButton.enabled = YES;
            self.retryButton.enabled = YES;
            
            [UIView animateWithDuration:0.6
                             animations:^{
                                 for (NSNumber *index in endCells) {
                                     NSUInteger i = [index integerValue];
                                     if ([self.board cellInIndexIsFree:i]) {
                                         [self.grid[i] setBackgroundColor:(__bridge CGColorRef)([The240GameViewController freeCellColor])];
                                         if (![self.board canFinishInIndex:i]) {
                                             [self.grid[i] setAlpha:1.0];
                                         }
                                     }
                                 }
                                 
                                 [self.gameStatistics highlightEndCells:[self level] gridSize:[self.gameInfo curGridSize]];
                             }];
        }
    }
    
    self.longPressUsed = YES;
}

#pragma mark Sharing via Facebook

- (IBAction)rate:(UIButton *)sender
{
    NSLog(@"Call rate function");
    
    [Flurry logEvent:@"Rate" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%lu", (unsigned long)[self.gameInfo curGridSize]], @"Grid Size",
                                             [NSString stringWithFormat:@"%lu", (unsigned long)self.board.score], @"Score",
                                             [NSString stringWithFormat:@"%lu", (unsigned long)[self.gameInfo bestScore]], @"Best Score",
                                             nil]];
    
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

- (IBAction)share:(UIButton *)sender
{
    NSLog(@"Call share function");
    
    NSString *applink = @"https://itunes.apple.com/il/app/id916255619";

    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:applink];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present the share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if (error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error in sharing: %@", error.description);
                                              
                                              [Flurry logEvent:@"Share failure" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                [NSString stringWithFormat:@"%lu", (unsigned long)[self.gameInfo curGridSize]], @"Grid Size",
                                                                                                [NSString stringWithFormat:@"%lu", (unsigned long)self.board.score], @"Score",
                                                                                                [NSString stringWithFormat:@"%lu", (unsigned long)[self.gameInfo bestScore]], @"Best Score",
                                                                                                nil]];
                                          }
                                          else {
                                              // Success
                                              NSLog(@"Success in sharing. Result: %@", results);
                                              
                                              [Flurry logEvent:@"Share success" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                [NSString stringWithFormat:@"%lu", (unsigned long)[self.gameInfo curGridSize]], @"Grid Size",
                                                                                                [NSString stringWithFormat:@"%lu", (unsigned long)self.board.score], @"Score",
                                                                                                [NSString stringWithFormat:@"%lu", (unsigned long)[self.gameInfo bestScore]], @"Best Score",
                                                                                                nil]];
                                          }
                                      }];
    }
    else {
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"240", @"name",
                                       @"The 240 Game", @"caption",
                                       @"Board/puzzle game - 240 moves to solve. Can you do it?", @"description",
                                       applink, @"link",
                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture", // TODO: update image (future)
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      }
                                                      else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled sharing.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled sharing.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"Sharing result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

#pragma mark Menu

- (IBAction)exitMenu:(UIButton *)sender
{
    [self exitMenu];
}

- (void)exitMenu
{
    self.menuIsOn = NO;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         for (UIButton *button in self.menuButtons) {
                             button.alpha = 0.0;
                         }
                         self.homeButton.alpha = 0.0;

                     }
                     completion:^(BOOL finished) {
                         
                         [self hideAndDisableMenuButtons];
                         
                         if (self.gameIsCompleted) {
                             
                             // Stay with an empty screen but allow buttons
                             
                             [self showAndEnableButtons:self.gameCompletionButtons];
                             
                             [UIView animateWithDuration:0.4
                                              animations:^{
                                                  for (UIButton *button in self.gameCompletionButtons) {
                                                      button.alpha = 1.0;
                                                  }
                                                  for (UIView *frame in self.frames) {
                                                      frame.alpha = 0.0;
                                                  }
                                                  [self setAlphaToScoreLabelsAndButtonsAndZeroAlphaForGameOverLabel:1.0];
                                              }
                                              completion:^(BOOL finished){
                                                  self.retryButton.enabled = YES;
                                                  self.menuButton.enabled = YES;
                                              }];
                         }
                         else {
                             [self animateFadeInBoardContinueGame];
                         }
                     }];
}

- (IBAction)menuRestartGame:(UIButton *)sender
{
    [self playSound:self.menuInSound];
    
    [self animateFadeInHelpTextArrayNoSkipButtonFromMenu:@[@"Are you sure?"]];
    
    self.helpTextTapAllowed = NO;
    
    for (UIButton *button in self.restartButtons) {
        button.alpha = 0.0;
        button.hidden = NO;
    }
    
    [UIView animateWithDuration:0.4
                          delay:0.4 // time for the menu to fade-out
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         for (UIButton *button in self.restartButtons) {
                             button.alpha = 1.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         for (UIButton *button in self.restartButtons) {
                             button.enabled = YES;
                         }
                     }];
}

- (void)animateFadeOutRestartButtons
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         for (UIButton *button in self.restartButtons) {
                             button.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         [self hideAndDisableButtons:self.restartButtons];
                     }];
}

- (IBAction)menuRestartOK:(UIButton *)sender
{
    [self.gameStatistics restart:[self level] gridSize:[self.gameInfo curGridSize]];
    
    [self restart];
    [self exitMenu];

    [self animateFadeOutHelpText];
    [self animateFadeOutRestartButtons];
    self.helpTextTapAllowed = YES;
}

- (IBAction)menuRestartCancel:(UIButton *)sender
{
    [self animateFadeOutHelpText];
    [self animateFadeOutRestartButtons];
    self.helpTextTapAllowed = YES;
}

- (void)deleteInfoFileHackLongPress:(UILongPressGestureRecognizer *)gesture
{
    NSAssert(self.deleteInfoFileHack, @"Button is a hack - cannot be called if delete info file hack boolean is false");
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.gameInfo deleteGameInfoFile];
        NSLog(@"Info file deleted");
    }
}

- (IBAction)menuGoBackOneLevel:(UIButton *)sender
{
    if ([self level] <= 1) {
        [self menuRestartOK:sender];
    }
    else {
        
        [self playSound:self.goBackOneLevelSound];
        
        [self.gameStatistics goBack:[self level] gridSize:[self.gameInfo curGridSize]];
        [self.gameInfo goBack:self.board];
        [self retryNoSound];
        [self exitMenu];
    }
}

- (IBAction)menuSinglesModeNextLevel:(UIButton *)sender
{
    BOOL curLevelGridIs4x4 = [self.singlesModeManager levelGridIs4x4];
    
    if (self.singlesModeManager.curLevel < self.singlesModeManager.maxLevel) {
        [self.singlesModeManager nextLevel];
    }
    else {
        NSLog(@"Logic error - button must not be available if level is the max level");
    }
    
    [self checkToggleGridSizeOnNextLevelSinglesMode:curLevelGridIs4x4];
    
    [self retry];
    [self exitMenu];
}

- (BOOL)checkToggleGridSizeOnNextLevelSinglesMode:(BOOL)prevLevelGridIs4x4
{
    if (prevLevelGridIs4x4 == [self.singlesModeManager levelGridIs4x4]) {
        [self loadBoardSinglesLevel];
        return NO; // No grid toggling was performed
    }
    else {
        [self resetBoard:STARTING_NUM_COLS+1 numRows:STARTING_NUM_ROWS+1];
        [self loadBoardSinglesLevel];
        [self loadBoardView];
        return YES;
    }
}

- (IBAction)menuSinglesModePreviousLevel:(UIButton *)sender
{
    BOOL curLevelGridIs4x4 = [self.singlesModeManager levelGridIs4x4];
    
    if (self.singlesModeManager.curLevel > 0) {
        [self.singlesModeManager prevLevel];
    }
    else {
        NSLog(@"Logic error - button must not be available if level is 0");
    }
    
    if (curLevelGridIs4x4 == [self.singlesModeManager levelGridIs4x4]) {
        [self loadBoardSinglesLevel];
    }
    else {
        [self resetBoard:STARTING_NUM_COLS numRows:STARTING_NUM_ROWS];
        [self loadBoardSinglesLevel];
        [self loadBoardView];
    }
    
    self.gameIsCompleted = NO;
    
    [self retry];
    [self exitMenu];
}

- (IBAction)menuSinglesModeLastLevel:(UIButton *)sender
{
    BOOL curLevelGridIs4x4 = [self.singlesModeManager levelGridIs4x4];
    
    if (self.singlesModeManager.curLevel < self.singlesModeManager.maxLevel) {
        [self.singlesModeManager lastLevel];
    }
    else {
        NSLog(@"Logic error - button must not be available if level is the max level");
    }
    
    [self checkToggleGridSizeOnNextLevelSinglesMode:curLevelGridIs4x4];
    
    [self retry];
    [self exitMenu];
}

- (IBAction)menuSinglesModeFirstLevel:(UIButton *)sender
{
    BOOL curLevelGridIs4x4 = [self.singlesModeManager levelGridIs4x4];
    
    if (self.singlesModeManager.curLevel > 0) {
        [self.singlesModeManager firstLevel];
    }
    else {
        NSLog(@"Logic error - button must not be available if level is 0");
    }
    
    if (curLevelGridIs4x4) {
        [self loadBoardSinglesLevel];
    }
    else {
        [self resetBoard:STARTING_NUM_COLS numRows:STARTING_NUM_ROWS];
        [self loadBoardSinglesLevel];
        [self loadBoardView];
    }
    
    self.gameIsCompleted = NO;
    
    [self retry];
    [self exitMenu];
}

- (IBAction)menuSoundToggle:(UIButton *)sender
{
    if (self.gameManager.soundIsOn) {
        [self.menuSoundToggleButton setTitle:@"Sound: Off" forState:UIControlStateNormal];
        self.gameManager.soundIsOn = NO;
    }
    else {
        [self.menuSoundToggleButton setTitle:@"Sound: On" forState:UIControlStateNormal];
        self.gameManager.soundIsOn = YES;
        [self playSound:self.menuInSound];
    }
    
    [self.gameManager save];
    
    [Flurry logEvent:@"Sound toggle" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSString stringWithFormat:@"%lu", (unsigned long)[self level]], @"Level",
                                                     [NSString stringWithFormat:@"%lu", (unsigned long)[self.gameInfo curGridSize]], @"Grid Size",
                                                     self.gameManager.soundIsOn ? @"ON" : @"OFF", @"To state",
                                                     nil]];
}

- (void)animateFadeInHelpTextArrayFromMenu:(NSArray *)helpTextArray withSkipButton:(BOOL)skipButton
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         for (UIButton *button in self.menuButtons) {
                             button.alpha = 0.0;
                         }
                         self.homeButton.alpha = 0.0;

                     }
                     completion:^(BOOL finished) {
                         [self hideAndDisableMenuButtons];
                         if (skipButton) {
                             [self animateFadeInHelpTextArrayWithSkipButton:helpTextArray withDelay:0.0];
                         }
                         else {
                             [self animateFadeInHelpTextArrayNoSkipButton:helpTextArray withDelay:0.0];
                         }
                     }];
}

- (void)animateFadeInHelpTextArrayWithSkipButtonFromMenu:(NSArray *)helpTextArray
{
    [self animateFadeInHelpTextArrayFromMenu:helpTextArray withSkipButton:YES];
}

- (void)animateFadeInHelpTextArrayNoSkipButtonFromMenu:(NSArray *)helpTextArray
{
    [self animateFadeInHelpTextArrayFromMenu:helpTextArray withSkipButton:NO];
}

- (IBAction)menuHowToPlay:(UIButton *)sender
{
    [self playSound:self.menuInSound];
    
    [Flurry logEvent:@"How to play" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSString stringWithFormat:@"%lu", (unsigned long)[self level]], @"Level",
                                                    [NSString stringWithFormat:@"%lu", (unsigned long)[self.gameInfo curGridSize]], @"Grid Size",
                                                    nil]];
    
    self.howToPlayTextView.hidden = NO;
    self.howToPlayTextView.alpha = 0.0;
    
    if (self.gameManager.singlesMode) {
        [self setHowToPlaySinglesModeText];
    }
    else {
        [self setHowToPlayStandardModeText];
    }
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         for (UIButton *button in self.menuButtons) {
                             button.alpha = 0.0;
                         }
                         self.homeButton.alpha = 0.0;
                         
                         for (UIView *frame in self.frames) {
                             frame.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         
                         [self hideAndDisableMenuButtons];
                         
                         [UIView animateWithDuration:0.4
                                          animations:^{
                                              self.howToPlayTextView.alpha = 1.0;
                                          }];
                     }];
}

- (void)animateFadeOutHowToPlayText
{
    [self showAndEnableButtons:self.menuButtons];
    [self showAndEnableButtons:@[self.homeButton]];
    self.homeButton.alpha = 0.0;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.howToPlayTextView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         self.howToPlayTextView.hidden = YES;
                         
                         [UIView animateWithDuration:0.4
                                          animations:^{
                                              
                                              for (UIButton *button in self.menuButtons) {
                                                  if (self.gameManager.singlesMode && (self.singlesModeNextButton == button ||
                                                                                       self.singlesModePrevButton == button ||
                                                                                       self.singlesModeLastButton == button ||
                                                                                       self.singlesModeFirstButton == button)) {
                                                      continue;
                                                  }
                                                  button.alpha = 1.0;
                                              }
                                              self.homeButton.alpha = 1.0;
                                              
                                              if (self.gameManager.singlesMode) {
                                                  [self updateSingleModeNextPrevButtons];
                                              }
                                              
                                              for (UIView *frame in self.frames) {
                                                  frame.alpha = 1.0;
                                              }
                                          }];
                     }];
}

#pragma mark Ads banner

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"iAdBanner failed");
    
    [Flurry logEvent:@"iAd load failed - loading AdMob"];
    
    GADRequest *request = [GADRequest request];
//    request.testDevices = @[ GAD_SIMULATOR_ID, @"MY_TEST_DEVICE_ID" ];
    request.testDevices = @[ @"4ce73c32a4c75414074e1b7dd75e191f" ];
    [self.gadBannerView loadRequest:request];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"iAdBanner loaded");
    
    [Flurry logEvent:@"iAd load success"];
}

#pragma mark Colors and Fonts

+ (UIColor *)freeCellColor
{
    return [UIColor colorWithRed:230/255.0 green:232/255.0 blue:250/255.0 alpha:1]; // Light blue/gray / "Silver"
}

+ (UIColor *)blockedCellColor
{
    return [The240GameViewController baseGameColor];
    
//    int i=-20;
//    return [UIColor colorWithRed:(112+i)/255.0 green:(128+i)/255.0 blue:(144+i)/255.0 alpha:1]; // Gray
//    return [UIColor colorWithRed:84/255.0 green:84/255.0 blue:84/255.0 alpha:1]; // Dark gray
}

+ (UIColor *)curCellColor
{
    return [UIColor colorWithRed:255/255.0 green:165/255.0 blue:0/255.0 alpha:1]; // Orange

//    return [UIColor colorWithRed:50/255.0 green:205/255.0 blue:50/255.0 alpha:1]; // Lime green
//    return [UIColor colorWithRed:34/255.0 green:139/255.0 blue:34/255.0 alpha:1]; // Forest green
//    return [UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:1]; // Dodger blue
    
//    return [UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1]; // Cyan
//    return [UIColor colorWithRed:35/255.0 green:107/255.0 blue:142/255.0 alpha:1]; // Dark turquoise / "Steel Blue"
}

// Unused
+ (UIColor *)cantFinishHereColor
{
    return [The240GameViewController freeCellColor];
    
//    return [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1]; // Light gray
//    return [UIColor colorWithRed:238/255.0 green:180/255.0 blue:34/255.0 alpha:1]; // Gold
}

+ (UIColor *)advanceLevelLabelColor
{
    return [UIColor colorWithRed:255/255.0 green:215/255.0 blue:0/255.0 alpha:1]; // Gold
    
//    return [UIColor colorWithRed:217/255.0 green:217/255.0 blue:25/255.0 alpha:1]; // Bright Gold
//    return [UIColor colorWithRed:207/255.0 green:181/255.0 blue:59/255.0 alpha:1]; // Old Gold
//    return [UIColor colorWithRed:238/255.0 green:180/255.0 blue:34/255.0 alpha:1]; // Gold
//    return [UIColor colorWithRed:255/255.0 green:215/255.0 blue:0/255.0 alpha:1]; // Yellow
}

+ (UIColor *)baseGameColor
{
    return [UIColor colorWithRed:16/255.0 green:78/255.0 blue:139/255.0 alpha:1.0]; // Dark blue
}

+ (UIColor *)endCellColor
{
    return [The240GameViewController advanceLevelLabelColor];
    
//    return [UIColor colorWithRed:238/255.0 green:232/255.0 blue:170/255.0 alpha:1.0]; // "PaleGoldenrod" yellow
//    return [UIColor colorWithRed:170/255.0 green:255/255.0 blue:252/255.0 alpha:1.0]; // Pale Cyan
}

+ (UIColor *)gridTogglingMenuButtonColor
{
    return [The240GameViewController curCellColor];
    
//    return [UIColor colorWithRed:184/255.0 green:115/255.0 blue:51/255.0 alpha:1.0]; // Copper
//    return [UIColor colorWithRed:190/255.0 green:69/255.0 blue:3/255.0 alpha:1.0]; // Brownish red
//    return [UIColor colorWithRed:238/255.0 green:44/255.0 blue:44/255.0 alpha:1.0]; // "Firebrick2" red
//    return [UIColor colorWithRed:255/255.0 green:67/255.0 blue:55/255.0 alpha:1.0]; // othe red
//    return [UIColor redColor];
}

- (UIColor *)getLevelColor
{
    NSAssert(self.recolorMode, @"can't call function not in recolor mode");
    
    NSArray* colors = @[ [The240GameViewController baseGameColor], // Dark blue
                         [UIColor redColor],
                         [UIColor colorWithRed:35/255.0 green:107/255.0 blue:142/255.0 alpha:1], // Dark turquoise
                         [UIColor greenColor]
                         ];
    
    NSUInteger numColors = [colors count];
    
    return colors[[self level] % numColors];
}

+ (UIFont *)gameFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNext-Heavy" size:size];
}

+ (UIFont *)advanceLevelLabelFont:(CGFloat)size
{
    return [UIFont fontWithName:@"AmericanTypewriter-Bold" size:size];
    
//    return [The240GameViewController gameFontWithSize:size];
}

@end
