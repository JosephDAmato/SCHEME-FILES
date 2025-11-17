;; This is a clojure based Database focused on retaining the history of data stored on it as such it can be audited. This is my first time in clojure so i am looking forward to learning new things. I will structure this project as I have learned in How to Design Programs course I took, there will be lots of comments

;; CONSTANTS

;; DATA DEFINITIONS
(defrecord Database [layers top-id cur time])
;; A Database is:
;;  - Layers = Reference ( Layer, Layer, ... )
;;  - top-id = Natural [ 0 - ... ] random
;;  - curr-time = Natural [ Time ]

#_ (define DB1 (->Database ) )
#_ (define DB2 ... )
#_
(defn fn-for-Database [db]
  (... (nfn-for-Layer(:layers db))    ;; Reference (Entities) 
       (:top-id db)                     ;; Natural
       (:cur-time db)))                 ;; Atomic Distinct Time

(defrecord Layer [storage VAET AVET VEAT EAVT])
;; Layer is:
;;  - storage = reference (Entity, Entity, ... )
;;  - VAET AVET VEAT EAVT = Indexes

#_ (defn fn-for-Layer [l]
  (... (fn-for-Layer(:layer l)) ;; Self Ref (Layer, Layer, ... )
       (:VAET l)                ;; Atomic Distinct ( Indexes )
       (:AVET l)
       (:VEAT l)
       (:EAVT l)))

(defrecord Entity [id attrs])
;; Entity is:
;;  - id  = String 'no-id-yet' or Natural [ 0 - ... ] random
;;  - attrs = Reference Attr [name, value ts prev-ts]

(defn fn-for-Entity [ent]
  ((fn-for-Attr))
  )

;; FUNCTIONS
