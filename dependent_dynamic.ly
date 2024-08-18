\version "2.24.2"

#(define flag #t)

#(define (add-dynamic music dyn)
   (let (
          (es (ly:music-property music 'elements))
          )
     (if (pair? es)
         (ly:music-set-property! music 'elements (map add-dynamic es dyn))
         (ly:music-set-property! music 'articulations (list (make-music 'AbsoluteDynamicEvent 'text (markup->string dyn))))
         )
     music))

addDynamic = #(define-music-function (m dyn) (ly:music? markup?) (add-dynamic m dyn))

addDependentDynamic = #(define-music-function (m dyn flag) (ly:music? markup? boolean?)
                         (if flag (add-dynamic m dyn) m))

showAlternate = #(define-music-function (altM m flag) (ly:music? ly:music? boolean?)
                   (if flag altM m))

#(define show-ritornello-dynamics
   (lambda (flag)
     (if flag
         (make-music 'TextScriptEvent 'text (markup #:line (#:dynamic "f"))))))

\header {
  tagline = ##f
}

\paper {
  #(set-paper-size '(cons ( * 6 in ) ( * 3 in )))
  indent = 0 \in
}

ritornello = #(define-music-function (is-reprise) (boolean?)
                #{
                  \relative f'' { f f f f #(show-ritornello-dynamics is-reprise) }
                #})

melody = \relative g' {
  \override TextScript.font-size = #-2
  \override TextScript.baseline-skip = #1
  g g g \addDependentDynamic g \markup "p" ##f
  g ^\markup \column {"skip event" "on beat 4"}  g g \addDependentDynamic s \markup "p" #flag

  g g g \showAlternate g {g \trill } ##t
  g g g \showAlternate g {g \trill } ##f
  g g g \showAlternate { g \p } g ##t
  g g g \showAlternate { g \p } g ##f
  #(define is-ritornello #f)
  g g g \displayMusic { g _\markup { \dynamic "f"} }
  g g g g #(if is-ritornello (make-music 'TextScriptEvent 'text (markup #:line (#:dynamic "f"))))
  #(set! is-ritornello #t)
  g g g g #(if is-ritornello (make-music 'TextScriptEvent 'text (markup #:line (#:dynamic "f"))))
  \override TextScript.color = #red
  #(set! is-ritornello #f)
  g g g g #(show-ritornello-dynamics is-ritornello)
  #(set! is-ritornello #t)
  g g g g #(show-ritornello-dynamics is-ritornello)
  \ritornello ##f
  \ritornello ##t
}

\book {
  \bookOutputName "dependent_dynamic"
  \score {
    \melody
  }
}
