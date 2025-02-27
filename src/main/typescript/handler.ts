import { App, Middleware, SlackEventMiddlewareArgs, StringIndexed } from "@slack/bolt";
import { inject, injectable, singleton } from "tsyringe";

@singleton()
export class SlackHandler {
    private app: App;

    constructor(@inject("SlackApp")  app: App) {
        this.app = app;
    }

    setup(): void {
        console.log("setup");
        this.app.message("hello", async ({message, say}) => {
            await say(`Hey there!`);
            console.log("say");
        });
    }
}