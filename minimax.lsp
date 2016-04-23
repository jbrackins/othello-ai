
#|
                  ***** MINIMAX.LSP *****

Generalized recursive minimax routine.

Author: Dr. John M. Weiss
Class:	SDSM&amp;T CSC447/547 Artificial Intelligence
Date: 	Spring 2016

Usage:    (minimax position depth)
          where position is the position to be evaluated,
          and depth is the search depth (number of plys).

Returns:  (value path)
          where value is the backed-up value from evaluation of leaf nodes,
          and path is the path to the desired leaf node.

Functions called:

          (deepenough depth) -
              predicate that returns T if the current position has reached
              the desired search depth, NIL otherwise.

          (move-generator position) -
              generates successors to the position.

          (static position) -
              applies the static evaluation function to the position.

          Note: these functions may need additional arguments.
|#
(load 'board-funcs)
(load 'heuristic-funcs)
(load 'print-funcs)

(setf _ALPHA_ -1000000)
(setf _BETA_  -1000000)

(defun deepenough (depth)
  (< depth 1)
)

(defun print-moves (list)
  (cond
    ( (null list) nil)
    (t
      (print-board (car list))
      (print-moves (cdr list))
    )
  )
)

(defun move-generator (position color)
  (loop for x in (get-valid-moves position color)
    collect (make-move-int position x color) 
  )
)

(defun static (position color)
  (weighted-parity position score-weights color)
)

(defun minimax (position depth color &optional (alpha? t) (alpha -100000) (beta -100000) )

  ; if we have searched deep enough, or there are no successors,
  ; return position evaluation and nil for the path
  (if (or (deepenough depth) (null (move-generator position color)))
    (list (static position color) nil)

        ; otherwise, generate successors and run minimax recursively
    (let
      (
        ; generate list of sucessor positions
        (successors (move-generator position color))

        ; initialize current best path to nil
        (best-path nil)

        ; initialize current best score to negative infinity
        (best-score -1000000)

                ; other local variables
        succ-value
        succ-score
      )

      ; explore possible moves by looping through successor positions
      (dolist (successor successors)

        ; perform recursive DFS exploration of game tree
        (setq succ-value (minimax successor (1- depth) (other-color color) (not alpha?) ))

        ; change sign every ply to reflect alternating selection
        ; of MAX/MIN player (maximum/minimum value)
        (setq succ-score (- (car succ-value)))

        ; update best value and path if a better move is found
        ; (note that path is being stored in reverse order)
        (when (> succ-score best-score)
          (setq best-score succ-score)
          (setq best-path (cons successor (cdr succ-value)))
        )
	(when (and alpha? (> best-score alpha))
	  (setf alpha best-score)
	  (print 'trimmed)
	  (return 2)
	)
	(when (and (not alpha?) (> best-score beta ))
	  (setf beta best-score)
	  (print 'trimmed)
	  (return 2)
	)

      )

            ; return (value path) list when done
      (list best-score best-path)
    )
  )
)
