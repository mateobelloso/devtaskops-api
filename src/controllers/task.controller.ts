import { Request, Response } from 'express';
import prisma from '../config/prisma';
import {
    createTaskSchema,
    updateTaskSchema
} from '../schemas/task.schema';

export const getTasks = async (_: Request, res: Response) => {
    const tasks = await prisma.task.findMany();

    res.json(tasks);
};

export const getTaskById = async (req: Request, res: Response) => {
    const id = Number(req.params.id);

    const task = await prisma.task.findUnique({
        where: { id }
    });

    if (!task) {
        return res.status(404).json({
            error: 'Task not found'
        });
    }

    res.json(task);
};

export const createTask = async (req: Request, res: Response) => {
    const validation = createTaskSchema.safeParse(req.body);

    if (!validation.success) {
        return res.status(400).json({
            errors: validation.error.flatten()
        });
    }

    const { title } = validation.data;

    const task = await prisma.task.create({
        data: {
            title
        }
    });

    res.status(201).json(task);
};

export const updateTask = async (req: Request, res: Response) => {
  const id = Number(req.params.id);

  const validation = updateTaskSchema.safeParse(req.body);

  if (!validation.success) {
    return res.status(400).json({
      errors: validation.error.flatten()
    });
  }

  const task = await prisma.task.update({
    where: { id },
    data: validation.data
  });

  res.json(task);
};

export const deleteTask = async (req: Request, res: Response) => {
    const id = Number(req.params.id);

    await prisma.task.delete({
        where: { id }
    });

    res.status(204).send();
};