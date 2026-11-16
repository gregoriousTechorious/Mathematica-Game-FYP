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
(* ---------- Level 1: Python vs Mathematica quiz ---------- *)
(* Edit this list to curate questions. "answer" is the position of the correct choice. *)
level1Questions = {
  <|"q" -> "In Python you call a function like sin(x). How do you call the sine function in the Wolfram Language?",
    "choices" -> {"sin(x)", "Sin(x)", "Sin[x]", "sin[x]"},
    "answer" -> 3,
    "explain" -> "Functions use square brackets, and built-in names are capitalised. Parentheses are only for grouping."|>,

  <|"q" -> "In Python, evaluating y + 2 when y was never defined raises a NameError. In Mathematica, with y undefined, what does y + 2 give?",
    "choices" -> {"An error, since y is not defined", "0", "2", "2 + y, kept as a symbolic expression"},
    "answer" -> 4,
    "explain" -> "Mathematica is a symbolic language. An undefined name is just a symbol, so the expression stays unevaluated and can be manipulated later."|>,

  <|"q" -> "Given lst = {10, 20, 30}, which expression returns the first element (10)?",
    "choices" -> {"lst[0]", "lst[[1]]", "lst(1)", "lst{1}"},
    "answer" -> 2,
    "explain" -> "Indexing uses double square brackets and starts at 1, not 0. Note that lst[[0]] returns the head of the expression, which is List."|>,

  <|"q" -> "Which line defines a function that squares any argument, like Python's def f(x): return x**2?",
    "choices" -> {"def f[x]: x^2", "f[x] := x^2", "f[x_] := x^2", "f(x_) = x^2"},
    "answer" -> 3,
    "explain" -> "The underscore in x_ is a pattern meaning 'any argument'. f[x] := x^2 would only define the rule for the literal symbol x."|>,

  <|"q" -> "Which is closest to Python's list comprehension [f(x) for x in lst]?",
    "choices" -> {"Map[f, lst]", "Apply[f, lst]", "f[[lst]]", "Do[f, lst]"},
    "answer" -> 1,
    "explain" -> "Map applies f to each element (shorthand: f /@ lst). Apply replaces the head instead, so f @@ {1,2,3} becomes f[1,2,3]."|>,

  <|"q" -> "In Python, 1/3 gives 0.3333333333333333. What does 1/3 give in Mathematica?",
    "choices" -> {"0.333333", "0.3333333333333333", "1/3, an exact rational number", "An error: integer division"},
    "answer" -> 3,
    "explain" -> "Mathematica keeps exact arithmetic by default. Use N[1/3] when you want a decimal approximation."|>,

  <|"q" -> "Which expression joins two strings in Mathematica?",
    "choices" -> {"\"abc\" + \"def\"", "\"abc\" <> \"def\"", "\"abc\" . \"def\"", "\"abc\" & \"def\""},
    "answer" -> 2,
    "explain" -> "<> is shorthand for StringJoin. Using + on strings does not concatenate them."|>,

  <|"q" -> "What is the underlying form of the expression x + y in Mathematica?",
    "choices" -> {"Plus[x, y]: everything is an expression of the form head[arguments]", "A string that is re-parsed each time", "A machine-precision float", "Nothing, since operators are not expressions"},
    "answer" -> 1,
    "explain" -> "Everything is an expression with a head and arguments. FullForm[x + y] shows Plus[x, y]. This uniform structure is what makes pattern matching and symbolic manipulation possible."|>,

  <|"q" -> "How does running code in a Mathematica notebook differ from running a Python script?",
    "choices" -> {"Cells always run top to bottom", "Each cell is a separate program with its own variables", "Code must be saved to a file before running", "Cells run one at a time, in any order, sharing one kernel session"},
    "answer" -> 4,
    "explain" -> "All cells share one kernel, so results depend on the order you evaluate them in. This is a common source of confusing bugs for newcomers."|>,

  <|"q" -> "Which is the Mathematica equivalent of Python's lambda x: x**2?",
    "choices" -> {"lambda[x]: x^2", "#^2 &", "x -> x^2", "(x) => x^2"},
    "answer" -> 2,
    "explain" -> "# is the argument slot and & marks the end of a pure function. x -> x^2 is a replacement rule, not a function. Also, ^ means power in Mathematica, whereas in Python it is XOR."|>
};

(* ---------- Quiz engine (reusable for any question list) ---------- *)
quizBody[questions_List] :=
  DynamicModule[{i = 1, picked = None, score = 0, n = Length[questions]},
    Pane[
      Dynamic@If[i > n,
        Column[{
          Style["Level complete!", 24, Bold],
          Style["Score: " <> ToString[score] <> " / " <> ToString[n], 18],
          Button["Try again", (i = 1; picked = None; score = 0)]
        }, Spacings -> 1.5],
        With[{qq = questions[[i]]},
          Column[{
            Style["Question " <> ToString[i] <> " of " <> ToString[n], 12],
            Pane[Style[qq["q"], 16, Bold], 520],
            Column[
              Table[
                With[{k = k},
                  Button[Pane[qq["choices"][[k]], 480],
                    (picked = k; If[k == qq["answer"], score++]),
                    ImageSize -> {520, Automatic},
                    Enabled -> (picked === None)]
                ],
                {k, Length[qq["choices"]]}
              ],
              Spacings -> 0.5],
            If[picked =!= None,
              Column[{
                Style[If[picked == qq["answer"], "Correct!",
                  "Not quite. The answer was: " <> qq["choices"][[qq["answer"]]]], Bold],
                Pane[qq["explain"], 520],
                Button[If[i == n, "See results", "Next question"], (i++; picked = None)]
              }, Spacings -> 1],
              ""]
          }, Spacings -> 1.2]
        ]
      ],
      {560, 330},
      Scrollbars -> {False, Automatic}
    ]
  ];

playBody := quizBody[level1Questions];

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
