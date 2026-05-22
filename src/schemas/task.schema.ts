import { z } from 'zod';

export const createTaskSchema = z.object({
  title: z
    .string()
    .min(3, 'Title must contain at least 3 characters')
});

export const updateTaskSchema = z.object({
  title: z
    .string()
    .min(3)
    .optional(),

  completed: z
    .boolean()
    .optional()
});