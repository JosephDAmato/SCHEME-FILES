;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname The_Corn_Maze) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

;; Corn Maze program
;; A simple maze game using BSL/Racket image library teachpack

;===========;;
;; CONSTANTS ;;
;;===========;;
;; CANVAS Constants
(define WIDTH 1750)
(define HEIGHT 1070)
(define CANVAS (rectangle WIDTH HEIGHT "outline" "dimgrey")) 
(define SPEED 5)

;; AVATAR
;; Interp as a collection of shapes in to represent a players pumpkin
(define mouth (triangle/sss 15 15 26  "solid" "black"))	
(define stem (rectangle 10 14 "solid" "brown"))
(define pump-eyes (beside (triangle 13 "solid" "black")(triangle 13 "solid" "black")))
pump-eyes
(define pumpkin-detail(overlay(ellipse  20 30 "solid" "orange")(ellipse  20 30 "outline" "black")))
(define AVATAR(overlay/offset mouth 0 (- 10)(overlay/offset (overlay/offset  pump-eyes  0 5
                                                                             (overlay/offset
                                                                              (overlay/offset pumpkin-detail (- 9) 0 pumpkin-detail)
                                                                              (- 12) 0 pumpkin-detail)) 0 (- 15) stem)))
;; TILES START ::;; TILES START ::;; TILES START ::;; TILES START ::;; TILES START ::;; TILES START ::;; TILES START ::;; TILES START :: 

;; Tile Textures

;; GROUND TILES are:
;;  - path-deadend
;;  - path-up
;;  - path-left
;;  - path-t
;;  - path-cross
;;  - corntile-one
;;  - corntile-two

;; BACKGROUND TILE
(define background (rectangle 100 100 "solid" "darkkhaki"))
;; PATH TILES
(define path-block (rectangle 55 100 "solid" "burlywood"))
;;  - DEAD END
(define path-deadend (place-image path-block 50 25 background))
;;  - UP
(define path-up (place-image path-block 50 50 background))
;;  - LEFT TURN
(define path-left (place-image (rotate 90 path-block) 25 50 path-deadend))
;;  - T-Intersection
(define path-t (place-image (rotate 90 path-block) 25 50(place-image path-block 50 50 background)))
;;  - CROSS INTERSECTION
(define path-cross (place-image (rotate 90 path-block) 50 50(place-image path-block 50 50 background)))
;; CORNLITTER
;;   - Intrep. as detail for groundtile
(define cornlitter (place-images/align
                    (list(triangle 48 "solid" "burlywood")
                         (triangle 48 "solid" "burlywood")
                         (triangle 48 "solid" "burlywood")
                         (triangle 48 "solid" "burlywood")
                         (triangle 48 "solid" "burlywood")
                         (triangle 48 "solid" "burlywood")
                         (triangle 48 "solid" "burlywood")
                         (triangle 48 "solid" "burlywood"))
                    (list(make-posn 100 32)(make-posn 100 48)(make-posn 100 100)
                         (make-posn 64 100)
                         (make-posn 64 64)
                         (make-posn 64 48)
                         (make-posn 64 32)
                         (make-posn 64 16)
                         )
                    "right" "bottom"
                    (rectangle 100 100 "outline" "mediumgoldenrod")))
;; LEFT and RIGHT LEAVES SHAPE
;;  - Intrep as different oriented leaves on a corn stalk
(define leaves-r (rotate 330(ellipse 12 30 "solid" "mediumforestgreen")))
(define leaves-l (rotate 30(ellipse 12 30 "solid" "mediumforestgreen")))
(define leaves-c (ellipse 12 30 "solid" "olive"))

;; LEFT AND RIGHT CORN SHAPE
;;  - Intrep as different oriented cobs on a corn stalk
(define corn-r (rotate 45 (wedge 22 32 "solid" "goldenrod")))
(define corn-l (rotate 100 (wedge 22 32 "solid" "goldenrod")))
(define corn-c (rotate 76 (wedge 22 32 "solid" "goldenrod")))
;; Combine with corn-r and corn-l for corncobs
(define corncob-r (overlay/offset corn-r -5 4 leaves-r))
(define corncob-l (overlay/offset corn-l 4 3 leaves-l))
(define corncob-c (overlay/offset corn-c 0 2 leaves-c))
;; STALK SHAPE
(define stalk (overlay/align "middle" "top" corn-c (rectangle 10 75 "solid" "olive")))
;;CORN STALK FINISHED SHAPE
(define cornstalk(overlay(overlay/offset leaves-l 21 -13  corncob-r) (overlay/offset  leaves-r -21 -33 corncob-l) stalk))
;; ========= ;;
;; CORNSTALK TILE construction
(define cornstalk-tile-foreground-one(overlay/offset cornstalk 42 22 cornstalk) )
(define cornstalk-tile-foreground-two(flip-horizontal cornstalk-tile-foreground-one) )
;; !!! Refactor into a compound data structure with x y postion for procedural generation !!!
(define corntile-one (overlay (overlay/offset cornstalk-tile-foreground-one 0 0  cornlitter)background))
(define corntile-two corntile-one)

  ;; this part was what made up corntile two, but i have removed it for sake of making the collision check faster
  ;; (overlay (overlay/offset cornstalk-tile-foreground-two 0 0  cornlitter)background))

  ;;====================;;
;;  DATA DEFINITIONS  ;;
;;====================;;

(define-struct Vector (x y ))
;; Vector is (make-vector (Natural [0, WIDTH] Natural [0, HEIGHT])
;;           - x is X Axis Coord
;;           - y is Y Axis Coord
;;  - Intrep as a postion within the SCENE in pixels
;;  EXAMPLES
(define V0(make-Vector 0 0))
(define V1(make-Vector (/ WIDTH 2) (/ HEIGHT 2)))

#;
(define (fn-for-vec v)
  (...(Vector-x v)
      (Vector-y v)))

;; Template Rules:
;;  - Compound Data
;;  - Atomic Non Distinct

;;===============;;
;;     MAZE      ;;
;;===============;;
;; Intrep as a list of lists that corespond to the x , y postioning of HARDCODED tiles.
;; !!! Future feature is to make procedurally generate.

(define MAZE   ;; Maze is a List of ListOfTiles
  (list
   (list corntile-two corntile-one                corntile-two               corntile-one                 corntile-two        corntile-one          corntile-two               corntile-one            corntile-two         corntile-one           corntile-two            corntile-one             (rotate 180 path-up)       corntile-one             corntile-two           corntile-one           corntile-two              corntile-two)                                                 
   (list corntile-one corntile-two               (rotate 180 path-deadend)   corntile-one                 corntile-two        corntile-one          corntile-two              (rotate 180 path-left)  (rotate 90 path-up)  (rotate 90 path-up)    (rotate 90 path-up)     (rotate 90 path-up)       (rotate 270 path-t)       (rotate 90 path-up)      (rotate 90 path-left)   corntile-one          (rotate 180 path-deadend)  corntile-one)
   (list corntile-two corntile-one               (rotate 180 path-t)        (rotate 90 path-up)          (rotate 90 path-up)  (rotate 90 path-up)  (rotate 90 path-up)         path-t                  corntile-two         corntile-one           corntile-two            corntile-one              corntile-two              corntile-one            (rotate 180 path-t)    (rotate 270 path-up)    path-t                    corntile-two)
   (list corntile-one corntile-two                path-up                    corntile-one                 corntile-two        corntile-one          corntile-two              (rotate 270 path-left)  (rotate 90 path-t)   (rotate 90 path-deadend)corntile-two           (rotate 270 path-deadend) (rotate 90 path-up)       (rotate 90 path-up)       path-t                 corntile-one           path-up                   corntile-one)
   (list corntile-two (rotate 270 path-deadend)   path-cross                 (rotate 90 path-up)          (rotate 90 path-left)        corntile-one          corntile-two               corntile-one            path-up              corntile-one           corntile-two            corntile-one              corntile-two              corntile-one            (rotate 180 path-t)    (rotate 90 path-up)     path-t                    corntile-two)
   (list corntile-one corntile-two                path-up                    corntile-one                path-deadend        corntile-one          corntile-two               corntile-one           (rotate 180 path-t)  (rotate 270 path-up)   (rotate 270 path-up)    (rotate 270 path-up)      (rotate 270 path-up)      (rotate 270 path-up)      path-left              corntile-one           path-up                   corntile-one)
   (list corntile-two corntile-one                path-up                    corntile-one                 corntile-two        corntile-one         (rotate 270 path-deadend)  (rotate 90 path-t)       path-left            corntile-one           corntile-two            corntile-one              corntile-two              corntile-one             corntile-two           corntile-one           path-up                   corntile-two)
   (list corntile-one (rotate 180 path-left)      path-cross                (rotate 90 path-up)          (rotate 90 path-up) (rotate 90 path-left)  corntile-two               path-up                 corntile-one         corntile-two          (rotate 180 path-left)  (rotate 270 path-up)      (rotate 270 path-up)      (rotate 270 path-up)     (rotate 270 path-up)   (rotate 90 path-t)      path-left                 corntile-one)
   (list corntile-two path-up                      path-up                    corntile-one                  corntile-two      (rotate 180 path-t)   (rotate 90 path-up)         path-cross             (rotate 270 path-up) (rotate 270 path-up)    path-t                  corntile-one              corntile-two              corntile-one             corntile-two          (rotate 270 path-left) (rotate 90 path-left)      corntile-two)
   (list corntile-one path-up                    (rotate 270 path-left)     (rotate 270 path-up)         (rotate 90 path-up)  path-left             corntile-two               path-deadend            corntile-two         corntile-one          (rotate 270 path-left)  (rotate 270 path-up)      (rotate 270 path-up)      (rotate 90 path-deadend)  corntile-two           corntile-one           path-deadend              corntile-one)
   (list corntile-one path-up                     corntile-two               corntile-one                 corntile-two        corntile-one          corntile-two               corntile-one            corntile-two         corntile-one           corntile-two            corntile-one              corntile-two              corntile-one             corntile-two           corntile-one           corntile-one              corntile-two) 
   ))
;; MAZE is:
;;  -empty
;; (ListofTiles, empty)
;; (ListofTiles, ListofTiles, empty)

;; FUNCTION TEMPLATES FOR MAZE, ListOfTiles
#;
(define (fn-for-maze mz)
  (cond [(empty? mz)(...)]
        [else
         (...(fn-for-ListOfTiles(first mz))
             (fn-for-maze (rest mz)))
         ]))
#;
(define (fn-for-ListOfTiles lot)
  (cond[(empty? lot)(...)]
       [else
        (...(first lot)
            (fn-for-ListOfTiles(rest lot)))]))
;; Template Rules Used:
;; - One of Two Cases:
;;   - empty
;;   - List of lists
;; - Reference      (first mz) (first lot) ListOfTiles
;; - Self Reference (rest  mz) (rest  lot)

;; MAZE(ListOfList) Natural Image-> Image
;; Places each tile according to its x ,y postion within a list of lists. Each inner list
;; represents a Y coord, each element in the these interal list is its x coord.
; Function Placing Maze onto Scene

(define (place-maze list-of-lists x scene) 
  (if (empty? list-of-lists)
      scene
      (place-maze (cdr list-of-lists)
                  (+ x 100) 
                  (place-column (car list-of-lists) x 50 scene))))

; Helper: list-of-tiles number number image -> image
; Places one column of tiles starting at x, y
(define (place-column list-of-tiles x y scene)
  (if (empty? list-of-tiles)
      scene
      (place-column(cdr list-of-tiles)
                   x (+ y 100)
                   (place-tile (car list-of-tiles) x y scene))))

; Hepler: tile number number image -> image
; Places a single tile at x, y on the scene 
(define (place-tile tile x y scene)
  (place-image tile  y x scene))
  
  ;;=========;;
;;  SCENE  ;;
;;=========;;
;; Scene is:
;;  - Placement of the tiles within MAZE upon the CANVAS

(define SCENE (place-maze MAZE 50 CANVAS))

;; MAZE END ::;; MAZE END ::;; MAZE END ::;; MAZE END ::;; MAZE END ::;; MAZE END ::;; MAZE END ::;; MAZE END ::;; MAZE END ::;; MAZE END ::

;; AVATAR START ::;; AVATAR START ::;; AVATAR START ::;; AVATAR START ::;; AVATAR START ::;; AVATAR START ::;; AVATAR START ::;; AVATAR START ::

;; DATA DEFINITIONS ;;
;;==================;;

(define-struct Avatar-Bounding-Box (t r b l))
;; Avatar-Bounding-Box is (make-Avatar-Bounding-Box Natural Natural Natural Natural)
;; Intrep. as:
;;            - t: Top of Bounding Box
;;            - r: Right of Bounding Box
;;            - b: Bottom of Bounding Box
;;            - l: Left of Bounding Box
;;             ( Follows Rotation as a clock )
;;            - Values are in pixel value
;; Avatar-Bounding-Box 'Example' defined within Avatar
#;
(define (fn-for-abb abb)
  (...(Avatar-Bounding-Box t)
      (Avatar-Bounding-Box r)
      (Avatar-Bounding-Box b)
      (Avatar-Bounding-Box l)))
;: Template Rules Used:
;;  - Compound Data: 1 case
;;    - Natural [0, WIDTH] or {0, HEIGHT]

(define-struct Avatar (img x y Avatar-Bounding-Box))
;; Avatar is (make-Avatar Image Natural[0, WIDTH Natural [0, WIDTH] Compound Data
;; interp. as
;;            - an image of player avatar
;;            - at its x y coord position within the scene in pixels

;; EXAMPLES
;; Middle of scene
(define A0 (make-Avatar AVATAR 0 0
                        (make-Avatar-Bounding-Box
                         (+ 0 (/ (image-height AVATAR) 2))
                         (+ 0 (/ (image-width  AVATAR) 2))
                         (+ 0 (/ (image-height AVATAR) 2))
                         (+ 0 (/ (image-width  AVATAR) 2)))))
(define A2 (make-Avatar AVATAR 0 0
                        (make-Avatar-Bounding-Box
                         (+ 50 (/ (image-height AVATAR) 2))
                         (+ 50 (/ (image-width  AVATAR) 2))
                         (+ 50 (/ (image-height AVATAR) 2))
                         (+ 50 (/ (image-width  AVATAR) 2)))))
(define A1 (make-Avatar AVATAR
                        (/ WIDTH 2) (/ HEIGHT 2)
                        (make-Avatar-Bounding-Box
                         (+ (/ HEIGHT 2)(/ (image-height AVATAR) 2))
                         (+ (/ WIDTH 2) (/ (image-width  AVATAR) 2))
                         (+ (/ HEIGHT 2)(/ (image-height AVATAR) 2))
                         (+ (/ WIDTH 2) (/ (image-width  AVATAR) 2)))))
;; In the starting path: use to run
(define START (make-Avatar AVATAR
                           150 1020
                           (make-Avatar-Bounding-Box
                            (+ 1020 (/ (image-height AVATAR) 2))
                            (+ 150(/ (image-width  AVATAR) 2))
                            (- 1020 (/ (image-height AVATAR) 2))
                            (- 150(/ (image-width  AVATAR) 2)))))

;; Avatar-Bounding-Box 'Example'
(define ABB1(make-Avatar-Bounding-Box
             (+ (Avatar-y A1)(image-height (Avatar-img A1)))
             (+ (Avatar-x A1)(image-width (Avatar-img A1)))
             (- (Avatar-y A1)(image-height (Avatar-img A1)))
             (- (Avatar-x A1)(image-width (Avatar-img A1)))))

#;
(define (fn-for-av av)
  (... (Avatar-img av)
       (Avatar-x   av)
       (Avatar-y   av)
       (fn-for-abb ps)))

;; Template Rules Used
;; - Compound Data: 2 cases
;;  - Image
;;  - Natural
;; - Reference (Avatar-Bounding-Box)

;; AVATAR END ::;; AVATAR END ::;; AVATAR END ::;; AVATAR END ::;; AVATAR END ::;; AVATAR END ::;; AVATAR END ::;; AVATAR END ::;; 




;; WOLRD START::;; WOLRD START::;; WOLRD START::;; WOLRD START::;; WOLRD START::;; WOLRD START::;; WOLRD START::;; WOLRD START::;; WOLRD START::
;;=================
;; Functions:

;; PS -> PS
;;   - PS is Player State
;;   - start the world with (main START)
;; 
(define (main ps)
  (big-bang ps                      ; PS
    (on-tick   tick-avatar .01)     ; PS -> PS
    (to-draw   render-avatar)       ; PS -> Image
    ;; (stop-when ...)              ; PS -> Boolean
    (on-key    move-avatar)))       ; PS KeyEvent -> PS

;; PS -> IMAGE
;; Places the avatar within the scene depending on the avatar's
;; world state

;(define (render-avatar ps)SCENE) ;STUB

;; Template from Above

(define (render-avatar ps)
  (place-image (Avatar-img ps)
               (Avatar-x   ps)
               (Avatar-y   ps) SCENE))

;; PS -> PS
;; Updates coord, computes bounding box, and feeds state of avatar to on-tock function

;; (define (tick-avatar ps) (make-Avatar AVATAR A1) ;STUB

;; Template from above
(define (tick-avatar ps)
  (make-Avatar (Avatar-img ps)
               (Avatar-x   ps)
               (Avatar-y   ps)
               (compute-bounding-box ps)))

;; Avatar KeyEvent -> Avatar
;; Takes in a left, right, up, down arrow input and updates
;; Avatar state according to its X Y axis

;; (define (move-avatar ps ky) A0) ;STUB

;; Template Used from Above calls tick to update state and edge-detect to
;; avoid moving out of scene
#;
(define (move-avatar ps ky)
  (cond[(string=? "left" ky)
        (tick-pos ps (- 1) 0)]
       [(string=? "right" ky)
        (tick-pos ps 1 0)]
       [(string=? "up" ky)
        (tick-pos ps 0 (- 1))]
       [ (string=? "down" ky)
         (tick-pos ps 0 1)]
       [else
        ps]))


(define (move-avatar ps ky)
  (cond[(string=? "left" ky)
        (if (wall-collision? ps MAZE 0 (- SPEED))
            (update-pos ps (- SPEED) 0)  ;;updates state
            (update-pos ps 5 0)                           ;;returns state
            )]
       [(string=? "right" ky)
        (if (wall-collision? ps MAZE 0 SPEED)
            (update-pos ps SPEED 0      );;update state
            (update-pos ps (- 5) 0)                           ;;return state
            )]
       [(string=? "up" ky)
        (if (wall-collision? ps MAZE (- SPEED) 0)
            (update-pos ps 0 (- SPEED))  ;;update state
            (update-pos ps 0 5)                           ;;return state
            )]
       [(string=? "down" ky)
        (if (wall-collision? ps MAZE SPEED 0)
            (update-pos ps 0 SPEED)      ;;update state
            (update-pos ps 0 (- 5))                           ;;return state
            )]
       [else
        ps]))
  
;; PS Natural Natural -> PS
;; Calculates New Player State

(define (update-pos ps x y)
  (tick-avatar
   (make-Avatar (Avatar-img ps)
                (+(Avatar-x   ps) (* x SPEED))
                (+(Avatar-y   ps) (* y SPEED))
                (compute-bounding-box ps))))



;;
;; Player State -> Boolean
;; Checks to see if player reaches the finish


;; PS MAZE(ListOfLists) SPEED-> Boolean
;; Detects Wall Collision on FALSE and avoids passing through wall tiles. If no collision detect, returns TRUE

;(define (wall-collision ps mz dx dy) A1) ;STUB


(define (wall-collision? ps lol dx dy)
  (cond[(= dy 0)
        (x-axis-check (Avatar-Avatar-Bounding-Box ps)(Avatar-x ps)(Avatar-y ps) lol dx)]
       [else
        (y-axis-check (Avatar-Avatar-Bounding-Box ps)(Avatar-x ps)(Avatar-y ps) lol dy)]))
;; Avatar-Bounding-Box MAZE  SPEED -> boolean
;; Checks for collision on the x axis

;(define (x-axis-check abb mz sp) true) ; STUB

(define (x-axis-check abb x-cord y-cord mz sp)
  (cond[(< sp 0)
        (overlap?(+(Avatar-Bounding-Box-l abb) sp) y-cord mz)] ;; (future x pos) y pos maze
       [else
        (overlap?(+(Avatar-Bounding-Box-r abb) sp) y-cord mz)]))
(define (y-axis-check abb x-cord y-cord mz sp)
  (cond[(< sp 0)
        (overlap? x-cord (+(Avatar-Bounding-Box-b abb) sp) mz)]  ;; (future x pos)          y pos   maze
       [else
        (overlap? x-cord (+(Avatar-Bounding-Box-t abb) sp) mz)]));;        x-cord   (future y pos)  maze    
;; Natural Natural ListOfLists (ListofTiles) -> Boolean
;; Takes in an x pos and y postion and checks if there is a corn-tile overlap

;;(define(overlap? x-cord y-cord lol) true) ;; STUB

(define (overlap? x-cord y-cord mz)
  (not (or (image=? (find-maze-pos x-cord y-cord mz) corntile-one)
         (image=? (find-maze-pos x-cord y-cord mz) corntile-two))))

;; Natural Natural ListOfLists -> Image (tile)
;; Returns the tile that coresponds to the x y cords

(define (find-maze-pos x-cord y-cord mz)
  (find-col x-cord (find-row y-cord mz)))

;; Natural ListOfTiles -> Image
;; Find the image according to its x pos in a list of images
(define (find-col x-cord lot)
  (cond [(< x-cord 100) (first lot)]
        [else
         (find-col (- x-cord 100) (rest lot))]))
;; Natural ListofLists -> ListofTiles
;; Finds a list from within a set of lists and returns the one corresponding to a y pos.
(define (find-row y-cord lol)
  (cond [(< y-cord 100) (first lol)]
        [else
         (find-row (- y-cord 100) (rest lol))]))
  
;; PS -> ABB
;; Takes in a players state and outputs a bounding box

(define (compute-bounding-box ps)
  (make-Avatar-Bounding-Box
   (+ (Avatar-y ps)(floor (/ (image-height (Avatar-img ps)) 2)))
   (+ (Avatar-x ps)(floor (/ (image-width  (Avatar-img ps)) 2)))
   (- (Avatar-y ps)(floor (/ (image-height (Avatar-img ps)) 2)))
   (- (Avatar-x ps)(floor (/ (image-width  (Avatar-img ps)) 2)))))

(main START)