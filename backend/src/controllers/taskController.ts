import { Router } from "express";
import { auth, AuthRequest } from "../middleware/auth";
import { NewTask, tasks } from "../db/schema";
import { db } from "../db";
import { eq, and, sql } from "drizzle-orm";

const taskRouter = Router();

taskRouter.post("/", auth, async (req: AuthRequest, res) => {
  try {
    req.body = { 
      ...req.body, 
      dueAt: new Date(req.body.dueAt), 
      uid: req.user 
    };
    const newTask: NewTask = req.body;

    const [task] = await db.insert(tasks).values(newTask).returning();

    res.status(201).json(task);
    return;
  } catch (e) {
    res.status(500).json({ error: e });
    return;
  }
});

taskRouter.get("/", auth, async (req: AuthRequest, res) => {
  try {
    const allTasks = await db
      .select()
      .from(tasks)
      .where(eq(tasks.uid, req.user!));

    res.json(allTasks);
    return;
  } catch (e) {
    res.status(500).json({ error: e });
    return;
  }
});

// Get tasks by specific date
taskRouter.get("/by-date", auth, async (req: AuthRequest, res) => {
  if (!req.query.date) {
    res.status(400).json({ error: "Date query param missing" });
    return; // <---- Add return here to stop further execution
  }
  try {
    const userId = req.user!;
    const dateString = req.query.date as string;

    // No need for this second check since the first one already returns early
    // if (!dateString) {
    //   return res.status(400).json({ error: "Date query param missing" });
    // }

    const date = new Date(dateString);
    const start = new Date(date);
    start.setHours(0, 0, 0, 0);
    const end = new Date(date);
    end.setHours(23, 59, 59, 999);

    const tasksByDate = await db
      .select()
      .from(tasks)
      .where(
        and(
          eq(tasks.uid, userId),
          sql`${tasks.dueAt} BETWEEN ${start} AND ${end}`
        )
      );

    res.json(tasksByDate);
    return; // <---- Add return here after successful response
  } catch (e) {
    res.status(500).json({ error: e });
    return; // <---- Add return here after error response
  }
});


taskRouter.delete("/", auth, async (req: AuthRequest, res) => {
  try {
    const { taskId }: { taskId: string } = req.body;
    await db.delete(tasks).where(eq(tasks.id, taskId));

    res.json(true);
    return;
  } catch (e) {
    res.status(500).json({ error: e });
    return;
  }
});

taskRouter.post("/sync", auth, async (req: AuthRequest, res) => {
  try {
    const tasksList = req.body;

    const filteredTasks: NewTask[] = [];

    for (let t of tasksList) {
      t = {
        ...t,
        dueAt: new Date(t.dueAt),
        createdAt: new Date(t.createdAt),
        updatedAt: new Date(t.updatedAt),
        uid: req.user,
      };
      filteredTasks.push(t);
    }

    const pushedTasks = await db
      .insert(tasks)
      .values(filteredTasks)
      .returning();

    res.status(201).json(pushedTasks);
    return;
  } catch (e) {
    console.log(e);
    res.status(500).json({ error: e });
    return;
  }
});

export default taskRouter;
