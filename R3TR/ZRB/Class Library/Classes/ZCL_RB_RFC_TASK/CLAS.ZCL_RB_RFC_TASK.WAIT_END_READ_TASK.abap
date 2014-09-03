method WAIT_END_READ_TASK.

  wait until nr_read_tasks = 0.

endmethod.
