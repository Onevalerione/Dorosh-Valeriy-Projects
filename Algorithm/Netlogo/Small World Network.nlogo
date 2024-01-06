extensions[ nw csv ]

turtles-own [speed
my-clustering-coefficient
distance-from-other-turtles
]

globals[
  clustering-coefficient-of-lattice
  clustering-coefficient
  average-path-length-of-lattice
  average-path-length
  infinity
  minority? id
]

to setup
  clear-all
  set-default-shape turtles "circle"
  set infinity 99999

  ifelse import-network?[
    nw:load-graphml user-file [ set color 125] ; Загрузка файла
  ]
  [


; Создание связей между агентами
    ask turtles [
        create-links-with n-of 1 (other turtles)
     ]
   ]




  ask links [ set color gray + 3 ]

  ask turtles
  [
  set Speed-of-turtles 1
  set speed Speed-of-turtles
  set Radius 10
  set acceleration 0.1
  vertex-degree
  set minority? false
  set size 0.6
  ]

  set clustering-coefficient find-clustering-coefficient
  set clustering-coefficient-of-lattice clustering-coefficient

  set average-path-length find-average-path-length
  set average-path-length-of-lattice average-path-length




  reset-ticks
end

to-report in-neighborhood? [ hood ]
  report ( member? end1 hood and member? end2 hood )
end

to-report find-clustering-coefficient

  let cc infinity

  ifelse all? turtles [ count link-neighbors <= 1 ] [

    set cc 0
  ][
    let total 0
    ask turtles with [ count link-neighbors <= 1 ] [ set my-clustering-coefficient "undefined" ]
    ask turtles with [ count link-neighbors > 1 ] [
      let hood link-neighbors
      set my-clustering-coefficient (2 * count links with [ in-neighborhood? hood ] /
                                         ((count hood) * (count hood - 1)) )

      set total total + my-clustering-coefficient
    ]
    ; take the average
    set cc total / count turtles with [count link-neighbors > 1]
  ]

  report cc
end


to-report find-average-path-length

  let apl 0


  find-path-lengths

  let num-connected-pairs sum [length remove infinity (remove 0 distance-from-other-turtles)] of turtles


  ifelse num-connected-pairs != (count turtles * (count turtles - 1)) [

    set apl infinity
  ][
    set apl (sum [sum distance-from-other-turtles] of turtles) / (num-connected-pairs)
  ]

  report apl
end


to find-path-lengths
  ask turtles [
    set distance-from-other-turtles []
  ]

  let i 0
  let j 0
  let l 0
  let node1 one-of turtles
  let node2 one-of turtles
  let node-count count turtles
  while [i < node-count] [
    set j 0
    while [ j < node-count ] [
      set node1 turtle i
      set node2 turtle j
      ifelse i = j [
        ask node1 [
          set distance-from-other-turtles lput 0 distance-from-other-turtles
        ]
      ][
        ifelse [ link-neighbor? node1 ] of node2 [
          ask node1 [
            set distance-from-other-turtles lput 1 distance-from-other-turtles
          ]
        ][
          ask node1 [
            set distance-from-other-turtles lput infinity distance-from-other-turtles
          ]
        ]
      ]
      set j j + 1
    ]
    set i i + 1
  ]
  set i 0
  set j 0
  let dummy 0
  while [l < node-count] [
    set i 0
    while [i < node-count] [
      set j 0
      while [j < node-count] [
        set dummy ( (item l [distance-from-other-turtles] of turtle i) +
                    (item j [distance-from-other-turtles] of turtle l))
        if dummy < (item j [distance-from-other-turtles] of turtle i) [
          ask turtle i [
            set distance-from-other-turtles replace-item j distance-from-other-turtles dummy
          ]
        ]
        set j j + 1
      ]
      set i i + 1
    ]
    set l l + 1
  ]

end


to export-network
  nw:save-graphml user-new-file
end

to go
  move-turtles
  tick
end

to move-turtles
  ask turtles [
    right random 360
    forward speed
  ]
end

to links-between-turtles
  ask turtles[
  let tries count my-links
  while[tries > 0][
    set tries tries - 1
    break-link
  ]
    vertex-degree
  ]


  set clustering-coefficient find-clustering-coefficient
  set average-path-length find-average-path-length

   set average-path-length-of-lattice average-path-length
  set clustering-coefficient-of-lattice clustering-coefficient
end


to break-link
  if any? link-neighbors ; равно true, если есть хотя бы один сосед. Это не цикл!
  [let furthest-friend max-one-of link-neighbors [distance myself] ; выбираем одного соседа - самого дальнего
  if distance furthest-friend > Radius ; равно true, если расстояние до этого соседа больше предела
  [ ask link-with furthest-friend [ die ] ; рвем связь с этим соседом
  ]
  ]
end


to limit
  if speed > 10[
   set speed 10
   set acceleration 0
]
if speed < 0[
   set speed 0
   set acceleration 0
]
end

to change-speed

  ask turtles[
    set speed Speed-of-turtles
    limit
  ]
end


to accelerate
  if ticks mod 15 = 0
  [
    ask turtles[
      set speed (speed + ( (random 3) - 1) * acceleration)
      limit
      show speed ; отладочные сообщения
    ]
  ]
end


to vertex-degree
  let dif  (k - count my-links)
  if dif > 0
  [
    create-links-with up-to-n-of dif other turtles in-radius Radius with [count my-links < k]
  ]
end
