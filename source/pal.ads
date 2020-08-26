package Pal is

   type Typ_Surface is tagged null record;
   type Rec_Event
      is record
         Typ    : Integer;
         Key    : Integer;
         Button : Integer;
         Pos_X  : Integer;
         Pos_Y  : Integer;
      end record;

   type Typ_Event   is access Rec_Event;

   type Typ_Color
      is record
         R, B, G : Integer;
      end record;

   procedure Init;

   package Display is

      function Set_Mode
        (Width, Height : Integer)
        return Typ_Surface;

      procedure Set_Caption
        (Text : String);

      procedure Update;

   end Display;

   procedure Fill
     (S : in out Typ_Surface;
     Color : Typ_Color);

   procedure Set_At
     (S    : in out Typ_Surface;
      X, Y : Integer;
      C    : Typ_Color);

   package Events is
      function Get return Typ_Event;
      function Is_Null (Event : Typ_Event) return Boolean;
      Quit              : constant := 1;
      Key_Up            : constant := 1;
      Key_Escape        : constant := 1;
      Mouse_Button_Down : constant := 1;
   end Events;

end Pal;
