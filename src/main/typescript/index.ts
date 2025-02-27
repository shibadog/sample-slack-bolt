import "reflect-metadata";
import { container, instanceCachingFactory } from "tsyringe";
import { App, AppOptions } from '@slack/bolt';
import c, { IConfig } from 'config';
import { SlackHandler } from "./handler";

container
    .register<IConfig>("Config", {
        useFactory: instanceCachingFactory<IConfig>(_ => c)
    })
    .register<App>("SlackApp", {
        useFactory: instanceCachingFactory<App>((c) => {
            const config = c.resolve<IConfig>("Config");
            return new App(config.get<AppOptions>("slack-options"));
        })
    })
;

(async () => { 
    const slackApp = container.resolve<App>("SlackApp");
    slackApp.message("hello", async ({message, say}) => {
        await say(`Hey there!`);
        console.log("say");
    });
    // Start your app
    await slackApp.start();

    slackApp.logger.info('⚡️ Bolt app is running!');
})();
