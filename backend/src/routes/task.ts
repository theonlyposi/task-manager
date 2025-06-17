import { Router, Request, Response } from "express";
import { sql, eq } from "drizzle-orm";
import { auth, AuthRequest } from "../middleware/auth";
import { db } from "../db";
import { NewTask, tasks } from "../db/schema";

const taskRouter = Router();

// ✅ Create Task
taskRouter.post("/", auth, async (req: Request, res: Response): Promise<void> => {
  try {
    const authReq = req as AuthRequest;
    const newTask: NewTask = {
      ...authReq.body,
      dueAt: new Date(authReq.body.dueAt),
      uid: authReq.user,
    };

    const [task] = await db.insert(tasks).values(newTask).returning();
    res.status(201).json(task);
  } catch (e) {
    res.status(500).json({ error: e });
  }
});

// ✅ Get All Tasks for Logged-in User
taskRouter.get("/", auth, async (req: Request, res: Response): Promise<void> => {
  try {
    const authReq = req as AuthRequest;
    const allTasks = await db.select().from(tasks).where(eq(tasks.uid, authReq.user!));
    res.json(allTasks);
  } catch (e) {
    res.status(500).json({ error: e });
  }
});

// ✅ Get Tasks by Specific Date
taskRouter.get("/by-date", auth, async (req: Request, res: Response): Promise<void> => {
  try {
    const authReq = req as AuthRequest;
    const { date } = req.query;

    if (!date || typeof date !== "string") {
      res.status(400).json({ error: "Date is required" });
      return;
    }

    const result = await db
      .select()
      .from(tasks)
      .where(
        sql`DATE(${tasks.dueAt}) = ${sql.placeholder("date")} AND ${tasks.uid} = ${sql.placeholder("uid")}`
      )
      .prepare("get-tasks-by-date")
      .execute({ date, uid: authReq.user });

    res.json(result);
  } catch (e) {
    res.status(500).json({ error: e });
  }
});

// ✅ Get Tasks by Date Range
taskRouter.get("/by-range", auth, async (req: Request, res: Response): Promise<void> => {
  try {
    const authReq = req as AuthRequest;
    const { start, end } = req.query;

    if (!start || !end || typeof start !== "string" || typeof end !== "string") {
      res.status(400).json({ error: "Start and end dates required" });
      return;
    }

    const result = await db
      .select()
      .from(tasks)
      .where(
        sql`DATE(${tasks.dueAt}) >= ${sql.placeholder("start")} AND DATE(${tasks.dueAt}) <= ${sql.placeholder("end")} AND ${tasks.uid} = ${sql.placeholder("uid")}`
      )
      .prepare("get-tasks-by-range")
      .execute({ start, end, uid: authReq.user });

    res.json(result);
  } catch (e) {
    res.status(500).json({ error: e });
  }
});

// ✅ Delete Task (by ID in URL param)
taskRouter.delete("/:id", auth, async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;

    const result = await db.delete(tasks).where(eq(tasks.id, id));

    if (result.rowCount === 0) {
      res.status(404).json({ message: "Task not found" });
      return;
    }

    res.json({ message: "Task deleted successfully" });
  } catch (e) {
    res.status(500).json({ error: e });
  }
});

// ✅ Update Task
taskRouter.patch("/", auth, async (req: Request, res: Response): Promise<void> => {
  try {
    const { taskId, ...updatedFields } = req.body;

    if (updatedFields.dueAt) {
      updatedFields.dueAt = new Date(updatedFields.dueAt);
    }

    const updatedTask = await db
      .update(tasks)
      .set(updatedFields)
      .where(eq(tasks.id, taskId))
      .returning();

    if (!updatedTask || updatedTask.length === 0) {
      res.status(404).json({ message: "Task not found" });
      return;
    }

    res.json(updatedTask[0]);
  } catch (e) {
    res.status(500).json({ error: e });
  }
});

// ✅ Sync Multiple Tasks
taskRouter.post("/sync", auth, async (req: Request, res: Response): Promise<void> => {
  try {
    const authReq = req as AuthRequest;
    const tasksList = req.body;

    const formattedTasks: NewTask[] = tasksList.map((t: any) => ({
      ...t,
      uid: authReq.user,
      dueAt: new Date(t.dueAt),
      createdAt: new Date(t.createdAt),
      updatedAt: new Date(t.updatedAt),
    }));

    const pushedTasks = await db.insert(tasks).values(formattedTasks).returning();
    res.status(201).json(pushedTasks);
  } catch (e) {
    res.status(500).json({ error: e });
  }
});

export default taskRouter;
