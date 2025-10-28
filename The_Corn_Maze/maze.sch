;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname maze) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)

;; 
;; Constants
;; ========== ;;

;; Tile Textures

;; GROUND TILES
;; Variable name list:
;;  - path-deadend
;;  - path-up
;;  - path-left
;;  - path-t
;;  - path-cross
;;  - corntile-one
;;  - corntile-two
;; =====created below===== ;;
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
;; detail for groundtile
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
(define leaves-r (rotate 330(ellipse 12 30 "solid" "mediumforestgreen")))
(define leaves-l (rotate 30(ellipse 12 30 "solid" "mediumforestgreen")))
(define leaves-c (ellipse 12 30 "solid" "olive"))
;;LEFT and RIGHT CORNCOBS SHAPE
;;   - Made of below...
;; LEFT AND RIGHT CORN SHAPE
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
(define corntile-one (overlay (overlay/offset cornstalk-tile-foreground-one 0 0  cornlitter)background))
(define corntile-two (overlay (overlay/offset cornstalk-tile-foreground-two 0 0  cornlitter)background))


;;  =========  ;;
;;  World Window
(define WIDTH 1750)
(define HEIGHT 970)
(define SCENE (rectangle WIDTH HEIGHT "outline" "dimgrey"))
(define MAZE
  (list
    (list path-deadend           path-deadend                corntile-one                 corntile-two        corntile-one         corntile-two              corntile-one          corntile-two        corntile-one         corntile-two            corntile-one         corntile-two          corntile-one            (rotate 90 path-left)        corntile-one           (rotate 180 path-deadend))
    (list corntile-one           corntile-two                corntile-one                 corntile-two        corntile-one         corntile-two              corntile-one          corntile-two        corntile-one         corntile-two            corntile-one         corntile-two          corntile-one            (rotate 180 path-t)  (rotate 270 path-up)   path-t)
    (list corntile-one           corntile-two                corntile-one                 corntile-two        corntile-one         corntile-two              corntile-one          corntile-two        corntile-one         corntile-two            corntile-one         corntile-two          corntile-one             path-t              corntile-one           path-up)
    (list corntile-one           corntile-two                corntile-one                 corntile-two        corntile-one         corntile-two              corntile-one          corntile-two        corntile-one         corntile-two            corntile-one         corntile-two          corntile-one             (rotate 180 path-t) (rotate 90 path-up)    path-t)
    (list corntile-one           corntile-two                corntile-one                 corntile-two        corntile-one         corntile-two              corntile-one          (rotate 180 path-t) (rotate 270 path-up) (rotate 270 path-up)    (rotate 270 path-up) (rotate 270 path-up) (rotate 270 path-up)      path-left           corntile-one           path-up)
    (list corntile-one           corntile-two                corntile-one                 corntile-two        corntile-one         (rotate 270 path-deadend) (rotate 90 path-t)    path-left           corntile-one         corntile-two            corntile-one         corntile-two          corntile-one              corntile-two        corntile-one           path-up)
    (list (rotate 180 path-left) path-cross                 (rotate 90 path-up)          (rotate 90 path-up) (rotate 90 path-left)  corntile-two              path-up              corntile-one        corntile-two         (rotate 180 path-left)  (rotate 270 path-up) (rotate 270 path-up) (rotate 270 path-up)      (rotate 270 path-up) (rotate 90 path-t)     path-left)
    (list path-up                path-up                    corntile-one                  corntile-two       (rotate 180 path-t)   (rotate 90 path-up)        path-cross          (rotate 270 path-up) (rotate 270 path-up) path-t                  corntile-one         corntile-two          corntile-one             corntile-two        (rotate 270 path-left) (rotate 90 path-left))
    (list path-up                (rotate 270 path-left)     (rotate 270 path-up)         (rotate 90 path-up)  path-left             corntile-two              path-deadend         corntile-two        corntile-one         (rotate 270 path-left)  (rotate 270 path-up) (rotate 270 path-up)  (rotate 90 path-deadend) corntile-two        corntile-one           path-deadend)
))   


; Function Placing Maze onto Scene

; place-maze: list-of-lists image -> image
; Places all maze tiles on the background scene
(define (place-maze list-of-lists x scene)
  (if (empty? list-of-lists)
      scene
     (place-maze (cdr list-of-lists)
                   (+ x 100) 
                   (place-column (car list-of-lists) x 50 scene))))

; place-column: list-of-tiles number number image -> image
; Places one column of tiles starting at x, y
(define (place-column list-of-tiles x y scene)
  (if (empty? list-of-tiles)
      scene
      (place-column(cdr list-of-tiles)
                   x (+ y 100)
                   (place-tile (car list-of-tiles) x y scene))))

; place-tile: tile number number image -> image
; Places a single tile at x, y on the scene 
(define (place-tile tile x y scene)
  (place-image tile  y x scene))

(place-maze MAZE 50 SCENE)