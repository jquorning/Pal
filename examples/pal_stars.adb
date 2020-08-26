pragma License (Restricted);
--
--    We are all in the gutter,
--    but some of us are looking at the stars.
--                                            -- Oscar Wilde
--
--  A simple starfield example. Note you can move the 'center' of
--  the starfield by leftclicking in the window. This example show
--  the basics of creating a window, simple pixel plotting, and input
--  event management.
--

with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;
with Ada.Numerics.Elementary_Functions;

with Pal;

-----------
-- Stars --
-----------

procedure Pal_Stars is

   subtype Typ_Surface is Pal.Typ_Surface;
   subtype Typ_Color   is Pal.Typ_Color;
   subtype Typ_Event   is Pal.Typ_Event;

   Winsize_X : constant := 640;
   Winsize_Y : constant := 480;

   Num_Stars   : constant := 150;

   package Starfields is

      subtype Typ_Pixel    is Integer;
      subtype Typ_Velocity is Float;
      subtype Typ_Position is Typ_Pixel;

      type Typ_Star
      is record
         Vel_X, Vel_Y : Typ_Velocity;
         Pos_X, Pos_Y : Typ_Position;
      end record;

      type Typ_Stars is
        array (Positive range <>) of Typ_Star;

      --
      --  Variables
      --
      Wincenter_X : Typ_Pixel := Winsize_X / 2;
      Wincenter_Y : Typ_Pixel := Winsize_Y / 2;

      --
      --  Sub-programs
      --
      procedure Initialize_Star (Star : out Typ_Star);
      --  Creates new star values.

      procedure Initialize_Field (Field : out Typ_Stars);
      --  Creates a new starfield.

      procedure Draw_Stars
        (Surface : in out Typ_Surface;
         Stars   :        Typ_Stars;
         Color   :        Typ_Color);
      --  Used to draw (and clear) the stars.

      procedure Move_Stars
        (Field : in out Typ_Stars);
      --  Animate the star values

   end Starfields;

   package body Starfields is

      type Typ_Range is range 0 .. 100_000 - 1;
      subtype Typ_Center_X_Position is Typ_Position range 0 .. Wincenter_X - 1;

--      package Random_Vel_Mults is
--        new Ada.Numerics.Float_Random (Typ_Unity);

      package Random_Ranges is
        new Ada.Numerics.Discrete_Random (Typ_Range);

      package Random_Centers is
        new Ada.Numerics.Discrete_Random (Typ_Center_X_Position);

      use Random_Ranges, Random_Centers, Ada.Numerics.Float_Random;

      Vel_Mult_Generator : Ada.Numerics.Float_Random.Generator;
      Range_Generator    : Random_Ranges.Generator;
      Center_Generator   : Random_Centers.Generator;

      ---------------------
      -- Initialize_Star --
      ---------------------

      procedure Initialize_Star (Star : out Typ_Star)
      is
         use Ada.Numerics.Elementary_Functions;

         Dir      : constant Typ_Range := Random (Range_Generator);
         Vel_Mult : constant Float     := Random (Vel_Mult_Generator) * 0.6 + 0.4;
         Vel_X    : constant Typ_Velocity := Sin (Float (Dir)) * Vel_Mult;
         Vel_Y    : constant Typ_Velocity := Cos (Float (Dir)) * Vel_Mult;
      begin
         Star := (Vel_X, Vel_Y, Wincenter_X, Wincenter_Y);
      end Initialize_Star;

      ----------------------
      -- Initialize_Field --
      ----------------------

      procedure Initialize_Field (Field : out Typ_Stars)
      is
      begin
         for Star of Field loop
            declare
               Steps : constant Typ_Velocity
                 := Typ_Velocity (Random (Center_Generator));
            begin
               Initialize_Star (Star);

               Star.Pos_X := Star.Pos_X + Typ_Position (Star.Vel_X * Steps);
               Star.Pos_Y := Star.Pos_Y + Typ_Position (Star.Vel_Y * Steps);

               Star.Vel_X := Star.Vel_X * Steps * 0.09;
               Star.Vel_Y := Star.Vel_Y * Steps * 0.09;
            end;
         end loop;
         Move_Stars (Field);
      end Initialize_Field;

      ----------------
      -- Draw_stars --
      ----------------

      procedure Draw_Stars
        (Surface : in out Typ_Surface;
         Stars   : Typ_Stars;
         Color   : Typ_Color)
      is
      begin
         for S of Stars loop
            declare
               Pos_X : constant Integer := S.Pos_X;
               Pos_Y : constant Integer := S.Pos_Y;
            begin
               Surface.Set_At (Pos_X, Pos_Y, Color);
            end;
         end loop;
      end Draw_Stars;

      ----------------
      -- Move_Stars --
      ----------------

      procedure Move_Stars
        (Field : in out Typ_Stars)
      is
      begin
         for S of Field loop
            S.Pos_X := S.Pos_X + Typ_Position (S.Vel_X);
            S.Pos_Y := S.Pos_Y + Typ_Position (S.Vel_Y);

            if
              S.Pos_X not in 0 .. Winsize_X
                or else
              S.Pos_Y not in 0 .. Winsize_Y
            then
               Initialize_Star (S);
            else
               S.Vel_X := S.Vel_X * 1.05;
               S.Vel_Y := S.Vel_Y * 1.05;
            end if;
         end loop;
      end Move_Stars;

   begin
      Reset (Vel_Mult_Generator);
      Reset (Range_Generator);
      Reset (Center_Generator);
   end Starfields;

   --
   --  This is the starfield code.
   --
   use Starfields;

   White : constant Typ_Color := (255, 240, 200);
   Black : constant Typ_Color := (20, 20, 40);

   Screen : Typ_Surface;

   Done   : Boolean;
   Field  : Typ_Stars (1 .. Num_Stars);
begin

   --  Create our starfield
   Initialize_Field (Field);

   --  Initialize and prepare screen
   Pal.Init;
   Screen := Pal.Display.Set_Mode (Winsize_X, Winsize_Y);
   Pal.Display.Set_Caption ("Agame Stars Example");
   Screen.Fill (Black);

   --  main game loop
   Done := False;
   while not Done loop
      Draw_Stars (Screen, Field, Black);
      Move_Stars (Field);
      Draw_Stars (Screen, Field, White);
      Pal.Display.Update;

      loop
         declare
            use Pal.Events;

            Event  : Typ_Event;
         begin
            Event := Pal.Events.Get;
            exit when Pal.Events.Is_Null (Event);

            if Event.Typ = Quit or (Event.Typ = Key_Up and Event.Key = Key_Escape) then
               Done := True;
               exit;
            elsif Event.Typ = Mouse_Button_Down and Event.Button = 1 then
               Wincenter_X := Event.Pos_X;
               Wincenter_Y := Event.Pos_Y;
            end if;
         end;
      end loop;
      delay 0.050;
   end loop;
end Pal_Stars;

--  Go where you have to go and
--    say what you have to say
--       because
--  Those who care do not mind and
--    those who mind do not care.
--                                   -- Anon ;-)
