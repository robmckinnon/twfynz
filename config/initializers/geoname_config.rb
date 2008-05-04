  SUPPRESS_GEONAMEIDS = [4032804] unless defined? SUPPRESS_GEONAMEIDS

  IGNORE_GEONAMES = ['Bennetts', 'Kiwi', 'Tasman', 'Moana', 'Tainui'] unless defined? IGNORE_GEONAMES

  NON_GEONAME_MATCH_TRIGGERS = %w[Mrs Mr Ms Miss Sir Dame Dr Professor Member for
    Lord Lady Viscount Earl Duke Duchess Baroness Baron
    Marquess Marquis Marchioness Marquise HMS
    Commander Colonel Captain Brigadier General Brigadier-General Lieut.-Colonel
    First Second Third Dispatch] unless defined? NON_GEONAME_MATCH_TRIGGERS

  NON_GEONAME_MATCH_TRIGGER_SUFFIX = %w[Fairbrother Fairbrothers Bishop
    McVeah McVeagh McVeaghs Norman Metirias Stanners
    Marshall Hyslop] unless defined? NON_GEONAME_MATCH_TRIGGER_SUFFIX

  GEONAME_STOP_WORDS = %w[The There That These Those They Thus This
    What Will Why Whom Therefore
    Monday Tuesday Wednesday Thursday Friday Saturday Sunday
    Does Behind But Having Where Most For Again Given Through Should
    Bill Amendment Joint Report Assent Act Section Standards Clauses Provisions
    Association Union Treaty Independent Regulation Limited Tax Fund Bank
    Liberal Democrat Labour Conservative Party English Welsh Scottish
    Standing Whip Inland Revenue Authority Treasury Financial Registry
    Electoral Finance Yes Now Parliament National Can No Zealand Australia
    State Mrs Order Paper Member Members House Speaker However
    Lord Lords Question Questions Moved Motion Sitting Interruption
    Secretary Health Committee Social Service Services Department
    Prime Minister Ministers Government Friend Friends When Select Leader Ever
    Further Dr Mr Mrs Sir Conference Office And Press
    Force Admiralty British German Allied Empire Empires Army
    During Our Country Parliament Commission She He It
    European Europe United Kingdom States President Agency Registrar
    January February March April May June July August September October November December
    Summer Recess Parliamentary Lordships His Her Perhaps Space
    International Organisations Commonwealth Federation Independence
    Security Tribunals Tribunal Council ] + NON_GEONAME_MATCH_TRIGGERS + IGNORE_GEONAMES unless defined? GEONAME_STOP_WORDS

