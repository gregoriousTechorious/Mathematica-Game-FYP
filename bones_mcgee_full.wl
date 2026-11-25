(* ::Package:: *)

(* Bones Mcgee Learns Mathematica - Main Menu - Wolfram Language *)

(* Settings *)
gameTitle     = "Bones Mcgee Learns Mathematica";
gameTitleTop  = "BONES MCGEE";
gameTitleSub  = "Learns Mathematica";
menuWidth     = 640;
menuHeight    = 600;

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

(* ====================================================================== *)
(* Chapter 1: Skeleton Cove - turn-based pirate battles                   *)
(* ====================================================================== *)

(* ---------- Enemy data (edit freely) ---------- *)
(* move types: attack, heavy, defend, steal, heal *)
c1Enemies = {
  <|"name" -> "Scuttle Crab", "hp" -> 24, "gold" -> 10,
    "moves" -> {
      <|"name" -> "Pinch", "type" -> "attack", "dmg" -> {3, 5}|>,
      <|"name" -> "Pinch", "type" -> "attack", "dmg" -> {3, 5}|>,
      <|"name" -> "Shell Up", "type" -> "defend"|>,
      <|"name" -> "Claw Smash", "type" -> "heavy", "dmg" -> {8, 10}|>}|>,
  <|"name" -> "Thieving Gull", "hp" -> 30, "gold" -> 15,
    "moves" -> {
      <|"name" -> "Peck", "type" -> "attack", "dmg" -> {4, 6}|>,
      <|"name" -> "Peck", "type" -> "attack", "dmg" -> {4, 6}|>,
      <|"name" -> "Snatch", "type" -> "steal"|>,
      <|"name" -> "Dive Bomb", "type" -> "heavy", "dmg" -> {9, 12}|>}|>,
  <|"name" -> "Captain Rotbeard", "hp" -> 60, "gold" -> 50,
    "moves" -> {
      <|"name" -> "Rusty Cutlass", "type" -> "attack", "dmg" -> {5, 8}|>,
      <|"name" -> "Rusty Cutlass", "type" -> "attack", "dmg" -> {5, 8}|>,
      <|"name" -> "Rally the Dead", "type" -> "heal"|>,
      <|"name" -> "Broadside", "type" -> "heavy", "dmg" -> {12, 16}|>}|>
};

(* ---------- Game state ---------- *)
c1NewGame[] := (c1State = <|
    "phase" -> "intro", "stage" -> 1,
    "pmax" -> 40, "php" -> 40, "bonus" -> 0, "potions" -> 2, "gold" -> 0,
    "cd" -> 0, "guarding" -> False, "eDefending" -> False, "lastGold" -> 0,
    "busy" -> False, "pending" -> "", "picked" -> None, "asked" -> <||>,
    "question" -> <|"q" -> "", "choices" -> {}, "answer" -> 1, "explain" -> ""|>,
    "log" -> {}, "ehp" -> 1, "emax" -> 1,
    "enemy" -> <|"name" -> "", "hp" -> 1, "gold" -> 0, "moves" -> {}|>,
    "intent" -> <|"name" -> "", "type" -> "attack", "dmg" -> {1, 1}|>|>;);
c1NewGame[];

c1Log[msg_String] := (c1State["log"] = With[{l = Append[c1State["log"], msg]}, Drop[l, Max[0, Length[l] - 4]]]);

c1PickIntent[] := (c1State["intent"] = RandomChoice[c1State["enemy"]["moves"]]);

c1StartFight[] := With[{e = c1Enemies[[c1State["stage"]]]},
  c1State["enemy"] = e;
  c1State["ehp"] = e["hp"];
  c1State["emax"] = e["hp"];
  c1State["eDefending"] = False;
  c1State["guarding"] = False;
  c1State["cd"] = 0;
  c1State["log"] = {"A " <> e["name"] <> " blocks your path!"};
  c1State["phase"] = "battle";
  c1PickIntent[]];

(* ---------- Learning hook: later, make this ask a Mathematica question ---------- *)
(* ---------- Question pools: one list per move ---------- *)
(* An empty list {} means that move needs no question yet.            *)
(* "answer" is the position (1-based) of the correct choice.          *)
(* Choices are shuffled automatically when a question is asked.       *)
c1Questions = <|
  "slash" -> {
    <|"q" -> "Which kind of brackets does Mathematica use to call a function?",
      "choices" -> {"Round, like Sin(x)", "Square, like Sin[x]", "Curly, like Sin{x}", "Angle, like Sin<x>"},
      "answer" -> 2,
      "explain" -> "Function calls use square brackets. Round brackets are only for grouping, and curly braces make lists."|>,
    <|"q" -> "What does Length[{4, 8, 15, 16}] return?",
      "choices" -> {"3", "4", "16", "43"},
      "answer" -> 2,
      "explain" -> "Length counts the elements of a list, and this list has four."|>,
    <|"q" -> "Given lst = {10, 20, 30}, how do you get the first element?",
      "choices" -> {"lst[[1]]", "lst[[0]]", "lst(1)", "lst.first"},
      "answer" -> 1,
      "explain" -> "Indexing uses double square brackets and starts at 1, not 0."|>,
    <|"q" -> "What does 2^3 evaluate to?",
      "choices" -> {"6", "8", "9", "5"},
      "answer" -> 2,
      "explain" -> "The ^ symbol means power, so 2^3 is 2 times 2 times 2, which is 8."|>,
    <|"q" -> "Which of these creates a list?",
      "choices" -> {"{1, 2, 3}", "(1, 2, 3)", "[1, 2, 3]", "<1, 2, 3>"},
      "answer" -> 1,
      "explain" -> "Curly braces make lists. Round brackets only group things, and square brackets call functions."|>,
    <|"q" -> "What does 1/3 give in Mathematica?",
      "choices" -> {"0.333333", "The exact fraction 1/3", "0", "An error"},
      "answer" -> 2,
      "explain" -> "Mathematica keeps exact arithmetic by default. Use N[1/3] if you want a decimal."|>,
    <|"q" -> "Which function gives a decimal approximation of Pi?",
      "choices" -> {"N[Pi]", "Decimal[Pi]", "Float[Pi]", "Approx[Pi]"},
      "answer" -> 1,
      "explain" -> "N converts exact values into approximate numbers. N[Pi] gives 3.14159."|>,
    <|"q" -> "Which key combination evaluates a cell in a notebook?",
      "choices" -> {"Enter", "Shift+Enter", "Ctrl+S", "Tab"},
      "answer" -> 2,
      "explain" -> "Shift+Enter evaluates the cell. Plain Enter just starts a new line."|>,
    <|"q" -> "What does Range[5] return?",
      "choices" -> {"{0, 1, 2, 3, 4}", "{1, 2, 3, 4, 5}", "{1, 2, 3, 4}", "5"},
      "answer" -> 2,
      "explain" -> "Range[n] gives the whole numbers from 1 up to n."|>,
    <|"q" -> "How do built-in Mathematica function names look?",
      "choices" -> {"All lowercase", "Capitalised, like Sqrt and Plot", "ALL CAPS", "Any case works"},
      "answer" -> 2,
      "explain" -> "Built-in names start with a capital letter, and the language is case sensitive."|>,
    <|"q" -> "What does Sqrt[2] give in Mathematica?",
      "choices" -> {"1.41421", "Sqrt[2], kept exact", "1", "An error"},
      "answer" -> 2,
      "explain" -> "Exact values stay symbolic. Use N[Sqrt[2]] to get 1.41421."|>,
    <|"q" -> "Which operator joins two strings together?",
      "choices" -> {"+", "<>", "&", "."},
      "answer" -> 2,
      "explain" -> "<> is shorthand for StringJoin, so \"ab\" <> \"cd\" gives \"abcd\"."|>,
    <|"q" -> "What does {1, 2, 3} + 10 give?",
      "choices" -> {"{11, 12, 13}", "{1, 2, 3, 10}", "An error", "16"},
      "answer" -> 1,
      "explain" -> "Arithmetic on a list is applied to every element, so each one gets 10 added."|>},
  "cannon" -> {},
  "guard" -> {},
  "rum" -> {}|>;

(* ---------- Player actions ---------- *)
c1CanAct["cannon"] := c1State["cd"] == 0;
c1CanAct["rum"] := c1State["potions"] > 0;
c1CanAct[_] := True;

c1Hit[dmg_, verb_String] := Module[{d, half = TrueQ[c1State["eDefending"]]},
  d = If[half, Ceiling[dmg/2], dmg];
  c1State["ehp"] = Max[0, c1State["ehp"] - d];
  c1Log[verb <> " hits for " <> ToString[d] <> " damage!" <> If[half, " (they were covering)", ""]]];

c1Effect["slash"] := c1Hit[RandomInteger[{5, 8}] + c1State["bonus"], "Cutlass slash"];
c1Effect["cannon"] := (c1Hit[RandomInteger[{13, 17}] + c1State["bonus"], "CANNON BLAST"]; c1State["cd"] = 3);
c1Effect["guard"] := (c1State["guarding"] = True; c1Log["Bones braces for the next blow."]);
c1Effect["rum"] := Module[{h},
  h = Min[15, c1State["pmax"] - c1State["php"]];
  c1State["php"] = c1State["php"] + h;
  c1State["potions"] = c1State["potions"] - 1;
  c1Log["Bones swigs rum and heals " <> ToString[h] <> " HP."]];

c1Resolve[action_String, success_] := (
  c1State["busy"] = True;
  If[action =!= "cannon", c1State["cd"] = Max[0, c1State["cd"] - 1]];
  c1State["guarding"] = False;
  If[TrueQ[success],
    c1Effect[action],
    c1Log["Wrong answer! Bones fumbles his " <> action <> " and loses his turn!"]];
  c1State["eDefending"] = False;
  Pause[0.9];   (* delay between your move and the enemy's move *)
  If[c1State["ehp"] <= 0, c1Victory[], c1EnemyTurn[]];
  c1State["busy"] = False);

(* Picks a random question from a move's pool, without repeats until the pool runs out *)
c1NextQuestion[move_String] := Module[
  {pool = Lookup[c1Questions, move, {}], used = Lookup[c1State["asked"], move, {}], avail, idx},
  avail = Complement[Range[Length[pool]], used];
  If[avail === {}, used = {}; avail = Range[Length[pool]]];
  idx = RandomChoice[avail];
  c1State["asked"] = Append[c1State["asked"], move -> Append[used, idx]];
  pool[[idx]]];

c1AskQuestion[action_String] := Module[{q = c1NextQuestion[action], perm},
  perm = RandomSample[Range[Length[q["choices"]]]];
  c1State["question"] = <|
    "q" -> q["q"],
    "choices" -> q["choices"][[perm]],
    "answer" -> FirstPosition[perm, q["answer"]][[1]],
    "explain" -> q["explain"]|>;
  c1State["pending"] = action;
  c1State["picked"] = None;
  c1State["phase"] = "question"];

c1Pick[k_Integer] /; c1State["phase"] === "question" && c1State["picked"] === None :=
  (c1State["picked"] = k);

c1QuestionDone[] /; c1State["phase"] === "question" && c1State["picked"] =!= None :=
  Module[{act = c1State["pending"], ok},
    ok = (c1State["picked"] === c1State["question"]["answer"]);
    c1State["busy"] = True;
    c1State["phase"] = "battle";
    c1Resolve[act, ok]];

(* Clicking a move: if it has a question pool, ask a question first; otherwise just do it *)
ClearAll[c1PlayerAct];
c1PlayerAct[action_String] /; c1State["phase"] === "battle" && ! TrueQ[c1State["busy"]] && c1CanAct[action] :=
  If[Lookup[c1Questions, action, {}] === {},
    c1Resolve[action, True],
    c1AskQuestion[action]];

(* ---------- Enemy turn ---------- *)
c1EnemyTurn[] := Module[{m = c1State["intent"], en = c1State["enemy"]["name"],
    guard = TrueQ[c1State["guarding"]], d, g},
  Switch[m["type"],
    "attack" | "heavy",
      (d = RandomInteger[m["dmg"]];
       If[guard, d = Ceiling[d/4]];
       c1State["php"] = Max[0, c1State["php"] - d];
       c1Log[en <> " uses " <> m["name"] <> " for " <> ToString[d] <> " damage" <>
         If[guard, " (guarded!)", ""] <> "."];
       If[guard && m["type"] === "heavy" && c1State["php"] > 0,
         c1State["ehp"] = Max[0, c1State["ehp"] - 6];
         c1Log["RIPOSTE! Bones counters for 6 damage!"]]),
    "defend",
      (c1State["eDefending"] = True;
       c1Log[en <> " uses " <> m["name"] <> " and takes cover."]),
    "steal",
      (g = Min[c1State["gold"], 6];
       c1State["gold"] = c1State["gold"] - g;
       c1State["php"] = Max[0, c1State["php"] - 2];
       c1Log[en <> " uses " <> m["name"] <> ": " <>
         If[g > 0, "steals " <> ToString[g] <> " gold", "finds your pockets empty"] <> " and pecks for 2."]),
    "heal",
      (c1State["ehp"] = Min[c1State["emax"], c1State["ehp"] + 8];
       c1Log[en <> " uses " <> m["name"] <> " and heals 8 HP."])
  ];
  c1State["guarding"] = False;
  Which[
    c1State["php"] <= 0, c1Defeat[],
    c1State["ehp"] <= 0, c1Victory[],
    True, c1PickIntent[]]];

c1Victory[] := Module[{g = c1State["enemy"]["gold"]},
  c1State["gold"] = c1State["gold"] + g;
  c1State["lastGold"] = g;
  c1Log[c1State["enemy"]["name"] <> " defeated! +" <> ToString[g] <> " gold."];
  c1State["phase"] = If[c1State["stage"] >= Length[c1Enemies], "won", "reward"]];

c1Defeat[] := (c1Log["Bones has been sent to Davy Jones' locker..."]; c1State["phase"] = "lost");

c1Upgrade[kind_String] := (
  Switch[kind,
    "dmg", c1State["bonus"] = c1State["bonus"] + 2,
    "hp", c1State["pmax"] = c1State["pmax"] + 10,
    "rum", c1State["potions"] = c1State["potions"] + 2];
  c1State["php"] = Min[c1State["pmax"], c1State["php"] + 12];
  c1State["stage"] = c1State["stage"] + 1;
  c1StartFight[]);

(* ---------- UI pieces ---------- *)
c1BtnFace[label_, en_, hov_, w_, h_] := Framed[
  Style[label, 14, Bold, If[en, White, GrayLevel[0.6]]],
  Background -> Which[! en, GrayLevel[0.3], hov, btnHover, True, btnColor],
  FrameStyle -> Directive[Thickness[2], If[en, btnFrame, GrayLevel[0.45]]],
  RoundingRadius -> 8,
  ImageSize -> {w, h},
  Alignment -> Center,
  FrameMargins -> 0];

ClearAll[c1Btn];
SetAttributes[c1Btn, HoldRest];
c1Btn[label_, action_, enabled_: True, w_: 130, h_: 34] :=
  With[{en = TrueQ[enabled]},
    Button[
      Mouseover[c1BtnFace[label, en, False, w, h], c1BtnFace[label, en, True, w, h]],
      action,
      Appearance -> "Frameless",
      Method -> "Queued",   (* lets the screen update during the delays *)
      Enabled -> en]];

c1HPBar[cur_, max_, w_: 140] := With[{f = N@Clip[cur/max, {0, 1}]},
  Graphics[{
    EdgeForm[{Thin, accentColor}], GrayLevel[0.12], Rectangle[{0, 0}, {1, 1}],
    Which[f > 0.5, palmGreen, f > 0.25, btnHover, True, Red],
    Rectangle[{0, 0}, {f, 1}]},
   PlotRange -> {{0, 1}, {0, 1}}, ImagePadding -> 0, AspectRatio -> Full,
   ImageSize -> {w, 14}]];

c1Sprite["Bones McGee"] := Graphics[{
  White, Disk[{0, 0.1}, 0.7], Rectangle[{-0.38, -0.75}, {0.38, -0.3}],
  Black, Disk[{-0.25, 0.12}, 0.15], Disk[{0.25, 0.12}, 0.15],
  Polygon[{{0, -0.05}, {-0.07, -0.2}, {0.07, -0.2}}],
  Thickness[0.012], Table[Line[{{x, -0.75}, {x, -0.3}}], {x, -0.2, 0.2, 0.13}],
  RGBColor[0.8, 0.1, 0.1], Rectangle[{-0.68, 0.42}, {0.68, 0.68}],
  accentColor, Thickness[0.02], Circle[{0.74, 0.0}, 0.1]},
  PlotRange -> {{-1, 1}, {-1, 1}}, ImageSize -> 80, ImagePadding -> 0];

c1Sprite["Scuttle Crab"] := Graphics[{
  RGBColor[0.85, 0.25, 0.2], Disk[{0, -0.1}, {0.6, 0.4}],
  Disk[{-0.8, 0.35}, 0.22], Disk[{0.8, 0.35}, 0.22],
  Thickness[0.02], Line[{{-0.5, -0.4}, {-0.85, -0.7}}], Line[{{-0.3, -0.45}, {-0.5, -0.85}}],
  Line[{{0.5, -0.4}, {0.85, -0.7}}], Line[{{0.3, -0.45}, {0.5, -0.85}}],
  Line[{{-0.2, 0.2}, {-0.2, 0.45}}], Line[{{0.2, 0.2}, {0.2, 0.45}}],
  White, Disk[{-0.2, 0.5}, 0.1], Disk[{0.2, 0.5}, 0.1],
  Black, Disk[{-0.2, 0.5}, 0.04], Disk[{0.2, 0.5}, 0.04]},
  PlotRange -> {{-1.1, 1.1}, {-1, 1}}, ImageSize -> 80, ImagePadding -> 0];

c1Sprite["Thieving Gull"] := Graphics[{
  White, Disk[{-0.1, -0.1}, {0.6, 0.45}], Disk[{0.5, 0.35}, 0.28],
  GrayLevel[0.75], Polygon[{{-0.4, 0}, {-0.95, 0.55}, {-0.1, -0.3}}],
  RGBColor[1, 0.8, 0.1], Polygon[{{0.75, 0.4}, {1.05, 0.3}, {0.75, 0.25}}],
  Black, Disk[{0.55, 0.42}, 0.05],
  Thickness[0.02], RGBColor[1, 0.6, 0.1], Line[{{-0.1, -0.5}, {-0.1, -0.9}}], Line[{{0.1, -0.5}, {0.1, -0.9}}]},
  PlotRange -> {{-1, 1.1}, {-1, 1}}, ImageSize -> 80, ImagePadding -> 0];

c1Sprite["Captain Rotbeard"] := Graphics[{
  RGBColor[0.7, 0.85, 0.95], Disk[{0, 0.2}, 0.6], Rectangle[{-0.6, -0.7}, {0.6, 0.2}],
  Table[Polygon[{{x - 0.2, -0.7}, {x, -1}, {x + 0.2, -0.7}}], {x, -0.4, 0.4, 0.4}],
  RGBColor[0.35, 0.2, 0.1], Polygon[{{-0.4, -0.15}, {0.4, -0.15}, {0.25, -0.65}, {-0.25, -0.65}}],
  Black, Disk[{-0.22, 0.25}, 0.12], Disk[{0.22, 0.25}, 0.12],
  Polygon[{{-0.8, 0.6}, {0.8, 0.6}, {0.35, 0.95}, {-0.35, 0.95}}],
  White, Disk[{0, 0.76}, 0.08]},
  PlotRange -> {{-1, 1}, {-1, 1}}, ImageSize -> 80, ImagePadding -> 0];

c1Sprite[_] := Graphics[Text[Style["?", 30]], ImageSize -> 80];

c1IntentColor["attack"] = btnHover;
c1IntentColor["heavy"] = RGBColor[1, 0.35, 0.3];
c1IntentColor["defend"] = RGBColor[0.5, 0.75, 1];
c1IntentColor["steal"] = accentColor;
c1IntentColor["heal"] = palmGreen;
c1IntentColor[_] = White;

c1IntentText[] := Module[{m = c1State["intent"], n = c1State["enemy"]["name"]},
  n <> " is about to use " <> m["name"] <> ": " <>
   Switch[m["type"],
     "attack", "a normal attack (" <> ToString[m["dmg"][[1]]] <> "-" <> ToString[m["dmg"][[2]]] <> " dmg).",
     "heavy", "a HEAVY attack (" <> ToString[m["dmg"][[1]]] <> "-" <> ToString[m["dmg"][[2]]] <> " dmg)! Guard to riposte.",
     "defend", "taking cover. Your next hit does half damage.",
     "steal", "it will steal your gold!",
     "heal", "it will heal itself.",
     _, ""]];

(* ---------- Screens ---------- *)
c1IntroView[] := Column[{
    Style["CHAPTER 1", 14, textColor],
    Style["Skeleton Cove", 30, Bold, accentColor],
    Pane[Style["Bones McGee has washed up on Skeleton Cove with an empty purse and a rumbling skull. Rumour says Captain Rotbeard hoards the island's treasure. Fight your way across the beach to reach him!", 14, textColor], 520],
    Column[{
      Style["\[Bullet] Slash: answer a question correctly to land a reliable hit.", 12, textColor],
      Style["\[Bullet] Cannon: huge damage, then a 3-turn cooldown.", 12, textColor],
      Style["\[Bullet] Guard: take 75% less damage, and riposte heavy attacks.", 12, textColor],
      Style["\[Bullet] Rum: heal 15 HP (limited supply).", 12, textColor],
      Style["Watch the enemy's next move and plan around it!", 12, Italic, accentColor]},
     Spacings -> 0.3, Alignment -> Left],
    c1Btn["Set Sail!", c1StartFight[], True, 200]
  }, Alignment -> Center, Spacings -> 1.2];

c1BattleView[] := Module[{e = c1State["enemy"], i = c1State["intent"], cd = c1State["cd"]},
  Column[{
    Row[{
      Pane[Column[{
         c1Sprite["Bones McGee"],
         Style["Bones McGee", 14, Bold, titleColor],
         c1HPBar[c1State["php"], c1State["pmax"]],
         Style["HP " <> ToString[c1State["php"]] <> "/" <> ToString[c1State["pmax"]], 12, textColor],
         Style["Bonus +" <> ToString[c1State["bonus"]], 11, textColor]},
        Alignment -> Center, Spacings -> 0.3], 170, Alignment -> Center],
      Pane[Column[{
         Style["Fight " <> ToString[c1State["stage"]] <> " / " <> ToString[Length[c1Enemies]], 14, accentColor],
         Style["VS", 30, Bold, btnHover],
         Style["Gold: " <> ToString[c1State["gold"]], 13, accentColor]},
        Alignment -> Center, Spacings -> 0.8], 170, Alignment -> Center],
      Pane[Column[{
         c1Sprite[e["name"]],
         Style[e["name"], 14, Bold, titleColor],
         c1HPBar[c1State["ehp"], c1State["emax"]],
         Style["HP " <> ToString[c1State["ehp"]] <> "/" <> ToString[c1State["emax"]], 12, textColor],
         Style[If[TrueQ[c1State["eDefending"]], "Covering!", " "], 11, RGBColor[0.5, 0.75, 1]]},
        Alignment -> Center, Spacings -> 0.3], 170, Alignment -> Center]
    }],
    Style[c1IntentText[], 13, Bold, c1IntentColor[i["type"]]],
    Framed[
      Pane[Column[
         MapIndexed[Style[#1, 12, If[#2[[1]] == Length[c1State["log"]], White, textColor]] &, c1State["log"]],
         Alignment -> Left, Spacings -> 0.2], {540, 64}],
      Background -> Darker[bgColor, 0.4], FrameStyle -> Directive[Thickness[1], btnFrame],
      RoundingRadius -> 6],
    Row[{
      Tooltip[c1Btn["Slash", c1PlayerAct["slash"], ! c1State["busy"]],
        "Answer a question correctly to deal 5-8 damage"],
      Tooltip[c1Btn[If[cd > 0, "Cannon (" <> ToString[cd] <> ")", "Cannon"], c1PlayerAct["cannon"],
          c1State["cd"] == 0 && ! c1State["busy"]],
        "13-17 damage, 3-turn cooldown"],
      Tooltip[c1Btn["Guard", c1PlayerAct["guard"], ! c1State["busy"]],
        "Take 75% less damage this turn. Riposte heavy attacks."],
      Tooltip[c1Btn["Rum (" <> ToString[c1State["potions"]] <> ")", c1PlayerAct["rum"],
          c1State["potions"] > 0 && ! c1State["busy"]],
        "Heal 15 HP"]
    }, Spacer[8]]
  }, Alignment -> Center, Spacings -> 0.7]];

c1RewardView[] := Column[{
    Style["Victory!", 28, Bold, accentColor],
    Style["+" <> ToString[c1State["lastGold"]] <> " gold plundered. Choose your loot:", 14, textColor],
    c1Btn["Sharper Cutlass: +2 damage", c1Upgrade["dmg"], True, 360],
    c1Btn["Sturdy Timbers: +10 max HP", c1Upgrade["hp"], True, 360],
    c1Btn["Rum Barrel: +2 rum", c1Upgrade["rum"], True, 360],
    Style["You also recover 12 HP.", 12, Italic, textColor]
  }, Alignment -> Center, Spacings -> 1];

c1WonView[] := Column[{
    Style["CHAPTER COMPLETE!", 28, Bold, accentColor],
    Pane[Style["Captain Rotbeard crumbles to dust, and the cove's treasure is yours.", 14, textColor], 480],
    Style["Gold plundered: " <> ToString[c1State["gold"]], 18, Bold, titleColor],
    Style["Chapter 2 coming soon...", 13, Italic, textColor],
    c1Btn["Play again", c1NewGame[], True, 200]
  }, Alignment -> Center, Spacings -> 1.3];

c1LostView[] := Column[{
    Style["DEFEATED", 30, Bold, RGBColor[1, 0.35, 0.3]],
    Pane[Style["Bones McGee has been sent to Davy Jones' locker. Even skeletons need a plan!", 14, textColor], 480],
    Style["Gold collected: " <> ToString[c1State["gold"]], 14, accentColor],
    c1Btn["Set sail again", (c1NewGame[]; c1StartFight[]), True, 200]
  }, Alignment -> Center, Spacings -> 1.3];

c1QuestionView[] := Module[{qq = c1State["question"], picked = c1State["picked"]},
  Pane[
    Column[{
      Style["Answer correctly to land your " <> c1State["pending"] <> "!", 13, accentColor],
      Pane[Style[qq["q"], 16, Bold, titleColor], 540],
      If[picked === None,
        Column[
          Table[
            With[{kk = k}, c1Btn[qq["choices"][[kk]], c1Pick[kk], True, 540, 30]],
            {k, Length[qq["choices"]]}],
          Spacings -> 0.5],
        Column[{
          Style[
            If[picked === qq["answer"],
              "Correct! Your move lands.",
              "Not quite! The answer was: " <> qq["choices"][[qq["answer"]]]],
            14, Bold, If[picked === qq["answer"], palmGreen, RGBColor[1, 0.35, 0.3]]],
          Pane[Style[qq["explain"], 13, textColor], 540],
          c1Btn["Continue", c1QuestionDone[], True, 200]},
         Alignment -> Center, Spacings -> 1]]
    }, Alignment -> Center, Spacings -> 1.2],
    {560, 340}, Scrollbars -> {False, Automatic}, Alignment -> Center]];

c1View[] := Switch[c1State["phase"],
  "intro", c1IntroView[],
  "battle", c1BattleView[],
  "question", c1QuestionView[],
  "reward", c1RewardView[],
  "won", c1WonView[],
  "lost", c1LostView[],
  _, ""];

(* Dynamic[...] stays unevaluated here, so the menu doesn't track c1State itself *)
c1Body := Pane[Dynamic[c1View[], TrackedSymbols :> {c1State}], {580, 350}, Alignment -> Center];

playBody := c1Body;

(* ====================================================================== *)
(* Options                                                                *)
(* ====================================================================== *)
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
