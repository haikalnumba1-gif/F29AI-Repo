(define (problem lunar-mission-1)
    (:domain lunar)

    (:objects
        WP1 WP2 WP3 WP4 WP5 - Waypoint
        Lander1 - Lander
        Rover1 - Rover
        Sample1 - Sample
        Image1 Scan1 - Data
    )

    (:init
        ;Node Init
        (node_Neighbour WP1 WP2) ; 1 > 2
        (node_Neighbour WP1 WP4) ; 1 > 4
        (node_Neighbour WP2 WP3) ; 2 > 3
        (node_Neighbour WP3 WP5) ; 3 > 5
        (node_Neighbour WP4 WP3) ; 4 > 3
        (node_Neighbour WP5 WP1) ; 5 > 1

        (node_HasSample WP1 Sample1)
        (node_HasData WP5 Image1)
        (node_HasData WP3 Scan1)

        ;Sample/Data Init
        (sample_TargetLander Sample1 Lander1)
        (data_TargetLander Image1 Lander1)
        (data_TargetLander Scan1 Lander1)

        ;Lander/Rover Init
        (lander_OwnsRover Lander1 Rover1)
        (lander_HasUndeployedRover Lander1)
    )

    (:goal
        (and
            (lander_HasSample Lander1 Sample1)
            (lander_IsHoldingSample Lander1)

            (lander_HasData Lander1 Image1)
            (lander_HasData Lander1 Scan1)
        )
    )
)