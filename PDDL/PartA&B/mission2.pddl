(define (problem lunar-mission-2)
    (:domain lunar)

    (:objects
        WP1 WP2 WP3 WP4 WP5 WP6 - Waypoint
        Lander1 Lander2 - Lander
        Rover1 Rover2 - Rover
        Alice Bob - Astronaut

        Sample1 Sample2 - Sample
        Img1 Img2 Scan1 Scan2 - Data ;1 for Lander1, 2 for Lander2
    )

    (:init

        ;Node Init
        (node_Neighbour WP1 WP2) ; 1 > 2
        (node_Neighbour WP2 WP1) ; 2 > 1
        (node_Neighbour WP2 WP3) ; 2 > 3
        (node_Neighbour WP2 WP4) ; 2 > 4
        (node_Neighbour WP3 WP5) ; 3 > 5
        (node_Neighbour WP4 WP2) ; 4 > 2
        (node_Neighbour WP5 WP3) ; 5 > 3
        (node_Neighbour WP5 WP6) ; 5 > 6
        (node_Neighbour WP6 WP4) ; 6 > 4
    
        (node_HasSample WP5 Sample1)
        (node_HasData WP3 Img1)
        (node_HasData WP6 Scan1)

        (node_HasSample WP1 Sample2)
        (node_HasData WP2 Img2)
        (node_HasData WP4 Scan2)

        ;Sample/Data Init
        (sample_TargetLander Sample1 Lander1)
        (data_TargetLander Img1 Lander1)
        (data_TargetLander Scan1 Lander1)

        (sample_TargetLander Sample2 Lander2)
        (data_TargetLander Img2 Lander2)
        (data_TargetLander Scan2 Lander2)

        ;Lander/Rover Init
        (lander_OwnsRover Lander1 Rover1)
            ;Manual drop: WP2
        (lander_HasDropped Lander1)
        (node_HasLander WP2 Lander1)
            ;Manual deploy.
        (rover_IsDeployed Rover1)
        (node_HasRover WP2 Rover1)

        (lander_OwnsRover Lander2 Rover2)
        (lander_HasUndeployedRover Lander2)

        ;Astr Init
        ;(astr_ExistsForLander Lander1)
        ;(astr_ExistsForLander Lander2)
        ;(astr_InLander Alice Lander1)
        ;(astr_InLander Bob Lander2)
        
        ;(astr_InDockingBay Alice)
        ;(astr_InControlRoom Bob)
    )

    (:goal
        (and
            (lander_HasSample Lander1 Sample1)
            (lander_IsHoldingSample Lander1)
            (lander_HasData Lander1 Img1)
            (lander_HasData Lander1 Scan1)

            (lander_HasSample Lander2 Sample2)
            (lander_IsHoldingSample Lander2)
            (lander_HasData Lander2 Img2)
            (lander_HasData Lander2 Scan2)
        )
    )
)