global_settings = {
    type = 1, -- The type of detection shape
    is_dynamic_freq = false, -- Whether the frequency is dynamic or not (scans at 5 Hz when nothing is detected, scans at freq Hz when something is detected)
    frequency = 40,-- The frequency of the sensor scans (in Hz) (also caps at 40)
}
