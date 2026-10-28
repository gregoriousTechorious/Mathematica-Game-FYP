(* ::Package:: *)

(* Bones Mcgee Learns Mathematica - Main Menu - Wolfram Language *)


(* Settings *)
gameTitle     = "Bones Mcgee Learns Mathematica";
gameTitleTop  = "BONES MCGEE";
gameTitleSub  = "Learns Mathematica";
menuWidth     = 640;
menuHeight    = 560;

(* Pirate colour scheme *)
bgColor       = RGBColor[0.02, 0.28, 0.33];   (* deep lagoon teal *)
btnColor      = RGBColor[0.45, 0.27, 0.12];   (* ship's wood brown *)
btnHover      = RGBColor[0.95, 0.55, 0.15];   (* sunset orange *)
btnFrame      = RGBColor[0.95, 0.8, 0.35];    (* gold trim *)
accentColor   = RGBColor[1, 0.82, 0.3];       (* treasure gold *)
titleColor    = RGBColor[0.98, 0.93, 0.75];   (* sand *)
textColor     = RGBColor[0.85, 0.95, 0.9];    (* sea foam *)
palmGreen     = RGBColor[0.35, 0.8, 0.5];

(* Reusable button with hover effect  *)
SetAttributes[menuButton, HoldRest];
menuButton[label_String, action_] :=
  DynamicModule[{hover = False},
    EventHandler[
      Dynamic@Framed[
        Style[label, 20, Bold, White],
        Background -> If[hover, btnHover, btnColor],
        FrameStyle -> Directive[Thickness[2], btnFrame],
        RoundingRadius -> 10,
        ImageSize -> {260, 50},
        Alignment -> Center,
        FrameMargins -> 0
      ],
      {
        "MouseEntered" :> (hover = True),
        "MouseExited"  :> (hover = False),
        "MouseClicked" :> action
      }
    ]
  ];

(* Generic page: title, subtitle, body, back button  *)
SetAttributes[simplePage, HoldAll];
simplePage[title_, subtitle_, body_, backAction_] :=
  Column[
    {
      Style[title, 40, Bold, titleColor],
      Style[subtitle, 16, textColor],
      Spacer[5],
      body,
      Spacer[5],
      menuButton["Back", backAction]
    },
    Alignment -> Center,
    Spacings -> 1.2
  ];

(* Tutorial content  *)
(* Edit this list to add, remove or reword sections: {heading, text} *)
tutorialSections = {
  {"1. It's a Symbolic Language",
   "Wolfram Language works with symbols, not just numbers. You can write x^2 + 3x without ever giving x a value, and it will happily manipulate it, e.g. expanding, factoring, differentiating or integrating it."},
  {"2. Everything Is an Expression",
   "Numbers, text, plots, images and even code itself are all expressions with the same underlying structure: head[arguments]. This uniformity is what makes the language so flexible."},
  {"3. Functions Use Square Brackets",
   "Functions are called like Sin[x] or Plot[x^2, {x, 0, 5}], not Sin(x). Built-in names start with a capital letter and are written in full (e.g. Length, not len). Parentheses are only for grouping, and curly braces { } make lists."},
  {"4. Huge Built-in Library",
   "Thousands of functions come built in: graphics, statistics, machine learning, image processing, geography, chemistry and more. Often one short line replaces dozens of lines in other languages."},
  {"5. Built-in Knowledge",
   "The language can pull in curated real-world data directly, such as countries, elements, and historical dates, using functions like Entity and EntityValue, and natural language input with Ctrl+="},
  {"6. Functional Style & Pattern Matching",
   "You can apply functions across lists with Map (/@), build pure functions with &, and transform expressions using rules (->) and patterns (x_). This is a very different way of thinking from loops-and-variables code."},
  {"7. Notebooks & Evaluation",
   "Code lives in notebooks made of input and output cells. Press Shift+Enter to evaluate a cell. Each result gets an Out[n] label, and you can mix code, text, and graphics freely."},
  {"8. Assignment: = vs :=",
   "x = 5 evaluates and stores the value immediately. f[x_] := x^2 defines a rule that is only evaluated when called. Knowing the difference is key to avoiding common bugs."},
  {"9. Interactivity Built In",
   "Functions like Manipulate and Dynamic let you make interactive controls and live-updating displays with almost no code. In fact, this menu is built with them!"}
};

section[title_String, text_String] :=
  Column[{
    Style[title, 18, Bold, accentColor],
    Pane[Style[text, 14, textColor], 540]
  }, Spacings -> 0.4];

tutorialBody :=
  Pane[
    Column[section @@@ tutorialSections, Spacings -> 2],
    {570, 270},
    Scrollbars -> {False, True},
    ScrollPosition -> {0, 0}
  ];

(*  Placeholder bodies (TODO)  *)
playBody :=
  Pane[
    Column[{
      Style["Chapter 1: The Sunken Chest", 20, Bold, accentColor],
      Style["LOREM IPSUM", 14, textColor]
    }, Spacings -> 1.5],
    {540, 270}
  ];

optionsBody :=
  Pane[
    Column[{
      Style["Options", 20, Bold, accentColor],
      Style["i doubt we'll need proper settings but just in case ig", 14, textColor],
      Style["\[Bullet] Sound: On / Off", 14, textColor],
      Style["\[Bullet] Difficulty: Cabin Boy / First Mate / Captain", 14, textColor],
      Style["\[Bullet] Reset progress", 14, textColor]
    }, Spacings -> 1.2, Alignment -> Left],
    {540, 270}
  ];

(* Quit: closes window  *)
quitGame[] := If[MatchQ[gameNB, _NotebookObject],
  NotebookClose[gameNB],
  NotebookClose[EvaluationNotebook[]]
];

(*  The main menu  *)
mainMenu[] :=
  DynamicModule[{screen = "menu"},
    Panel[
      Dynamic@Switch[screen,
        "menu",
          Column[
            {
              Style[gameTitleTop, 50, Bold, accentColor],
              Style[gameTitleSub, 30, Bold, titleColor],
              Spacer[25],
              menuButton["Play",     screen = "play"],
              menuButton["Tutorial", screen = "tutorial"],
              menuButton["Options",  screen = "options"],
              menuButton["Quit",     quitGame[]]
            },
            Alignment -> Center,
            Spacings -> 1.5
          ],
        "play",
          simplePage["PLAY", "Your adventure begins here", playBody, screen = "menu"],
        "tutorial",
          simplePage["TUTORIAL", "What makes the Wolfram Language different?", tutorialBody, screen = "menu"],
        "options",
          simplePage["OPTIONS", "Tweak your ship", optionsBody, screen = "menu"]
      ],
      Background -> bgColor,
      ImageSize -> {menuWidth, menuHeight},
      Alignment -> Center,
      FrameMargins -> 30
    ]
  ];

(*  Launch it  *)
gameNB = CreateDocument[mainMenu[],
  WindowTitle -> gameTitle,
  WindowSize -> All,
  Selectable -> False,        (* no clicking/selecting text, no blinking cursor *)
  Editable -> False,          (* nothing can be typed or changed *)
  ShowSelection -> False,     (* hides the selection highlight *)
  ShowCellBracket -> False,   (* removes the bracket on the right edge *)
  WindowToolbars -> {},       (* no toolbar at the top *)
  CellInsertionPointCell -> {}  (* hides the horizontal insertion line between cells *)
]
