(* ::Package:: *)
(* Basic game main menu - Wolfram Language *)

(* ---------- Settings you can tweak ---------- *)
gameTitle    = "MY GAME";
gameSubtitle = "An epic adventure awaits";
menuWidth    = 640;
menuHeight   = 520;
bgColor      = RGBColor[0.08, 0.09, 0.16];
btnColor     = GrayLevel[0.2];
btnHover     = RGBColor[0.25, 0.5, 0.9];

(* ---------- Reusable button with hover effect ---------- *)
SetAttributes[menuButton, HoldRest];
menuButton[label_String, action_] :=
  DynamicModule[{hover = False},
    EventHandler[
      Dynamic@Framed[
        Style[label, 20, Bold, White],
        Background -> If[hover, btnHover, btnColor],
        FrameStyle -> GrayLevel[0.5],
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

(* ---------- The main menu screen ---------- *)
mainMenu[] :=
  DynamicModule[{status = " "},
    Panel[
      Column[
        {
          Style[gameTitle, 52, Bold, White],
          Style[gameSubtitle, 16, LightGray],
          Spacer[30],
          menuButton["Play",    status = "Play clicked (hook up your game here)"],
          menuButton["Options", status = "Options clicked"],
          menuButton["Quit",    status = "Quit clicked"],
          Spacer[20],
          Dynamic@Style[status, 12, Gray]
        },
        Alignment -> Center,
        Spacings -> 1.5
      ],
      Background -> bgColor,
      ImageSize -> {menuWidth, menuHeight},
      Alignment -> Center,
      FrameMargins -> 30
    ]
  ];

(* ---------- Launch it ---------- *)
CreateDocument[mainMenu[], WindowTitle -> gameTitle, WindowSize -> All]
