'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
'                      Bells, Whistles, and Sound Boards
'       Copyright (c) 1993-95, Edward Schlunder. All Rights Reserved.
'ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
' GDMTYPE.BI - GDM module header/sample type definitions.
'              Written by Edward Schlunder (1994-95)
'
'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

TYPE GDMHeader
  ID                    AS STRING * 4            'ID: 'GDMþ'
  SongTitle             AS STRING * 32           'Music's title
  SongMusician          AS STRING * 32           'Name of music's composer
  DOSEOF                AS STRING * 3            '10, 13, 26
  ID2                   AS STRING * 4            'ID: 'GDMF'
  FormMajorVer          AS STRING * 1            'Format major version
  FormMinorVer          AS STRING * 1            'Format minor version
  TrackID               AS INTEGER               'Composing Tracker ID code
  TrackMajorVer         AS STRING * 1            'Tracker's major version
  TrackMinorVer         AS STRING * 1            'Tracker's minor version
  PanMap                AS STRING * 32           '0-Left to 15-Right, 255-N/U
  MastVol               AS STRING * 1            '0..64
  Tempo                 AS STRING * 1            'Initial music tempo (6)
  BPM                   AS STRING * 1            'Initial music BPM (125)
  FormOrigin            AS INTEGER               'Original format ID:
   '1-MOD, 2-MTM, 3-S3M, 4-669, 5-FAR, 6-ULT, 7-STM, 8-MED, 9-PSM
   '(versions of 2GDM prior to v1.15 won't set this 100% correctly)

  OrdOffset             AS LONG
  NOO                   AS STRING * 1            'Number of orders in module
  PatOffset             AS LONG
  NOP                   AS STRING * 1            'Number of patterns in module
  SamHeadOffset         AS LONG
  SamOffset             AS LONG
  NOS                   AS STRING * 1            'Number of samples in module
  MTOffset              AS LONG
  MTLength              AS LONG
  SSOffset              AS LONG
  SSLength              AS INTEGER
  TGOffset              AS LONG
  TGLength              AS INTEGER
END TYPE

TYPE SamHeader
  SamName               AS STRING * 32  '32
  FileName              AS STRING * 12  '44
  EmsHandle             AS STRING * 1   '45
  Length                AS LONG         '49
  LoopBegin             AS LONG         '53
  LoopEnd               AS LONG         '57
  Flags                 AS STRING * 1   '58
  C4Hertz               AS INTEGER      '60
  Volume                AS STRING * 1   '61
  Pan                   AS STRING * 1   '62
  Segment               AS INTEGER
END TYPE

TYPE SamHeader2
  SamName               AS STRING * 32  '32
  FileName              AS STRING * 12  '44
  EmsHandle             AS STRING * 1   '45
  Length                AS LONG         '49
  LoopBegin             AS LONG         '53
  LoopEnd               AS LONG         '57
  Flags                 AS STRING * 1   '58
  C4Hertz               AS INTEGER      '60
  Volume                AS STRING * 1   '61
  Pan                   AS STRING * 1   '62
END TYPE

