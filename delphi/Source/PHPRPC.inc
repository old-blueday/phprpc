{$define Delphi}

// FreePascal

{$ifdef fpc}
  {$mode delphi}   // Set FreePascal to Delphi mode
  {$asmmode Intel} // Default is att
  {$packset 1}     // Default is 4
  {$undef DELPHI}
{$endif}

// Delphi

{$ifdef Delphi}

  // Delphi version

  {$ifdef VER150}
    {$define DELPHI7}
    {$define DELPHI7_UP}
  {$endif}

  {$ifdef VER160}
    {$define DELPHI8}
    {$define DELPHI8_UP}
  {$endif}

  {$ifdef VER170}
    {$define DELPHI2005}
    {$define DELPHI2005_UP}
  {$endif}

  {$ifdef VER180}
    {$ifdef VER185}
      {$define DELPHI2007}
      {$define DELPHI2007_UP}
    {$else}
      {$define DELPHI2006}
      {$define DELPHI2006_UP}
    {$endif}
  {$endif}

  {$ifdef VER200}
    {$define DELPHI2009}
    {$define DELPHI2009_UP}
  {$endif}

  {$ifdef VER210}
    {$define DELPHI2010}
    {$define DELPHI2010_UP}
  {$endif}

  // Delphi version up

  {$ifdef DELPHI2010_UP} {$define DELPHI2009_UP} {$endif}
  {$ifdef DELPHI2009_UP} {$define DELPHI2007_UP} {$endif}
  {$ifdef DELPHI2007_UP} {$define DELPHI2006_UP} {$endif}
  {$ifdef DELPHI2006_UP} {$define DELPHI2005_UP} {$endif}
  {$ifdef DELPHI2005_UP} {$define DELPHI8_UP}    {$endif}
  {$ifdef DELPHI8_UP}    {$define DELPHI7_UP}    {$endif}

{$endif}

// FreePascal and Delphi features

{$ifdef fpc}
  {$define Supports_Inline}
{$endif}

{$ifdef Delphi}

  {$ifdef DELPHI2005_UP}
    {$define Supports_For_In}
    {$define Supports_Inline}
    {$define Supports_Nested_Constants}
    {$define Supports_Nested_Types}
    {$define Supports_Region}
  {$endif}

  {$ifdef DELPHI2006_UP}
    {$define Supports_Class_Fields}
    {$define Supports_Class_Helpers}
    {$define Supports_Class_Operators}
    {$define Supports_Strict}
    {$define Supports_Static}
    {$define Supports_Final}
  {$endif}

  {$ifdef DELPHI2009_UP}
    {$define Supports_Generics}
    {$define Supports_Unicode}
  {$endif}

{$endif}
