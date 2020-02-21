
proc template ;
   define style TStyleRTF ;
      parent=styles.rtf ;

      style table from table /
         Background=_UNDEF_
         rules=groups   /* PUTS BOTTOM BORDER ON ROW HEADERS */
         frame=above
         cellspacing=1.0
         cellpadding=1.0
         borderwidth=1.5pt
         ;

      replace fonts /
         'TitleFont2'         = ("Times New Roman",10pt,Bold)
         'TitleFont'          = ("Times New Roman",10pt,Bold)
         'StrongFont'         = ("Times New Roman",10pt,Bold)
         'EmphasisFont'       = ("Times New Roman",10pt,Italic)
         'FixedEmphasisFont'  = ("Times New Roman",10pt,Italic)
         'FixedStrongFont'    = ("Times New Roman",10pt,Bold)
         'FixedHeadingFont'   = ("Times New Roman",10pt)
         'BatchFixedFont'     = ("Times New Roman",10pt)
         'FixedFont'          = ("Times New Roman",10pt)
         'headingEmphasisFont'= ("Times New Roman",10pt,Italic)
         'headingFont'        = ("Times New Roman",10pt,Bold)    /* FONT FOR COLUMN HEADERS */
         'docFont'            = ("Times New Roman",9pt)
         ;

      replace Body from Document /
         bottommargin = .75in
         topmargin    = 1.25in
         rightmargin  = 1in
         leftmargin   = 1in
         ;

      replace HeadersAndFooters from cell /
         font = fonts('HeadingFont')
         foreground = _undef_/*colors('headerfg')*/
         background = _undef_/*lightgrey*/
         ;

      replace TitlesAndFooters from Container /
         font = Fonts('TitleFont')
         background = _undef_
         foreground = _undef_/*colors('headerfg')*/
         rules = ALL
         just  = CENTER
         ;

      replace PageNo from Container /
         font        = Fonts('docFont')
         background  = colors('systitlebg')
         foreground  = colors('systitlefg')
         cellspacing = 0
         cellpadding = 0
         ;
   end ;

define style PStyleRTF ;        /* PORTRAIT FOR IN-TEXT TABLES */
      parent=styles.rtf ;

      style table from table /
         Background =_UNDEF_
         cellpadding=3pt      /* AMOUNT OF WHITE SPACE ON EACH OF THE FOUR SIDES OF THE CONTENT IN A CELL - IF 0 THEN LINES DISAPPEAR IN PDF */
         borderwidth=.5pt
         ;

      replace fonts /
         'TitleFont2'         = ("Times New Roman, Arial",10pt,Bold)
         'TitleFont'          = ("Times New Roman, Arial",10pt,Bold)
         'StrongFont'         = ("Times New Roman, Arial",10pt,Bold)
         'EmphasisFont'       = ("Times New Roman, Arial",10pt,Italic)
         'FixedEmphasisFont'  = ("Times New Roman, Arial",10pt,Italic)
         'FixedStrongFont'    = ("Times New Roman, Arial",10pt,Bold)
         'FixedHeadingFont'   = ("Times New Roman, Arial",10pt)
         'BatchFixedFont'     = ("Times New Roman, Arial",10pt)
         'FixedFont'          = ("Times New Roman, Arial",10pt)
         'headingEmphasisFont'= ("Times New Roman, Arial",10pt,Italic)
         'headingFont'        = ("Times New Roman, Arial",10pt,Bold)    /* FONT FOR COLUMN HEADERS */
         'docFont'            = ("Times New Roman, Arial",10pt)
         ;
      replace Body from Document /
         bottommargin = 1in
         topmargin    = 1in
         rightmargin  = 1in
         leftmargin   = 1in
         ;
      replace HeadersAndFooters from cell /
         font = fonts('HeadingFont')
         foreground = colors('headerfg')
         background = _UNDEF_     /* #DCDCDC LIGHT GRAY - _UNDEF_ if need clear background */
         ;
      replace TitlesAndFooters from Container /
         font = Fonts('TitleFont')
         background = _undef_
         foreground = colors('systitlefg')
         rules = ALL
         just  = CENTER
         ;
      replace PageNo from Container /
         font        = Fonts('docFont')
         background  = colors('systitlebg')
         foreground  = colors('systitlefg')
         cellpadding = 0
         ;
   end ;

 run ;

