method WAIT_END_ALL_TASK.

  wait until nr_max_tasks = nr_free_tasks.

endmethod.
