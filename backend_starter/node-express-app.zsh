# Create project directory
echo "Enter your project name:"
read project_name
mkdir $project_name
cd $project_name

# # Initialize Node.js project
yarn init -y

# Install necessary packages
yarn add express cors morgan dotenv pino pino-pretty mongoose
yarn add typescript @types/express @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint pino-http --dev

touch tsconfig.json
touch .env
touch eslintrc.js
touch .gitignore

mkdir -p src/controllers
mkdir -p src/services
mkdir -p src/repositories
mkdir -p src/middleware
mkdir -p src/model
mkdir -p src/router

cd src
touch server.ts
touch app.ts
touch mongodb.ts
touch logger.ts

# Create basic files
touch controllers/index.ts services/index.ts repositories/index.ts

# Populate .env file
cd ..
echo '
PORT=8080
DB_NAME=test
MONGODB_URI=mongodb://127.0.0.1:27017

PINO_LOG_LEVEL=info
' > .env

cd src
# Populate logger.ts
echo '
import pino from "pino";

const levels = {
  emerg: 80,
  alert: 70,
  crit: 60,
  error: 50,
  warn: 40,
  notice: 30,
  info: 20,
  debug: 10,
};

// create a transport
const transport = pino.transport({
  targets: [
    {
      target: "pino-pretty",
      options: {
        destination: "./logs/output.log",
        mkdir: true,
        colorize: false,
      },
    },
    {
      target: "pino-pretty",
      options: { destination: process.stdout.fd },
    },
  ],
});

// Configure Pino logger
const logger = pino(
  {
    level: process.env.PINO_LOG_LEVEL || "info",
    customLevels: levels,
    redact: { paths: ["email", "password", "address"], remove: true },
    timestamp: pino.stdTimeFunctions.isoTime,
  },
  transport
);

export default logger;
' > logger.ts

# Populate mongodb.ts
# Mongodb connection setup
echo '
import mongoose from "mongoose";
import logger from "./logger";

export const mongodbConnection = async () => {
  try {
    const mongooseOpt: mongoose.ConnectOptions = {
      dbName: process.env.DB_NAME,
    };

    await mongoose.connect(process.env.MONGODB_URI || "", mongooseOpt);

    logger.info("Database connected successfully");
  } catch (error) {
    logger.error(error);
  }
};
' > mongodb.ts

# Populate app.ts
echo '
import express, { NextFunction, Request, Response } from "express";
import { configDotenv } from "dotenv";
import { pinoHttp } from "pino-http";

const app = express();
app.use(express.json({ limit: "60mb" }));
app.use(pinoHttp());
configDotenv();

// Define routes
/**
 * Testing route
 */
app.get("/", (request: Request, response: Response, next: NextFunction) => {
  response.send("Softwish server is up and running 🚀");
});

export default app;
' > app.ts

# Populate server.ts with initial setup
echo '
import logger from "./logger";
import app from "./app";
import { mongodbConnection } from "./mongodb";

const port = process.env.PORT || 8080;
mongodbConnection().finally(() => {
  app.listen(port, () => {
    logger.info(`Server is running on port: ${port}`);
  });
});
' > server.ts

# Update package.json with start script
cd ..
jq '.scripts += {"start": "ts-node src/server.ts"}' package.json > tmp.json && mv tmp.json package.json

echo '
{
  "compilerOptions": {
    "target": "es2016",
    "lib": [
      "ESNext",
      "DOM"
    ] /* Specify a set of bundled library declaration files that describe the target runtime environment. */,
    "experimentalDecorators": true /* Enable experimental support for TC39 stage 2 draft decorators. */,
    "emitDecoratorMetadata": true /* Emit design-type metadata for decorated declarations in source files. */,

    /* Modules */
    "module": "commonjs" /* Specify what module code is generated. */,
    "rootDir": "./src" /* Specify the root folder within your source files. */,
    "moduleResolution": "node" /* Specify how TypeScript looks up a file from a given module specifier. */,
    "baseUrl": "." /* Specify the base directory to resolve non-relative module names. */,

    /* JavaScript Support */
    "allowJs": true /* Allow JavaScript files to be a part of your program. Use the 'checkJS' option to get errors from these files. */,
    // "checkJs": true,                                  /* Enable error reporting in type-checked JavaScript files. */

    /* Emit */
    // "outFile": "./",                                  /* Specify a file that bundles all outputs into one JavaScript file. If 'declaration' is true, also designates a file that bundles all .d.ts output. */
    "outDir": "./dist" /* Specify an output folder for all emitted files. */,
    "removeComments": true /* Disable emitting comments. */,
    "sourceMap": true,

    /* Interop Constraints */
    "esModuleInterop": true /* Emit additional JavaScript to ease support for importing CommonJS modules. This enables 'allowSyntheticDefaultImports' for type compatibility. */,
    "forceConsistentCasingInFileNames": true /* Ensure that casing is correct in imports. */,

    /* Type Checking */
    "strict": true /* Enable all strict type-checking options. */,
    "noImplicitAny": true /* Enable error reporting for expressions and declarations with an implied 'any' type. */,

    /* Completeness */
    "skipLibCheck": true /* Skip type checking all .d.ts files. */
  },
  "exclude": ["node_modules", "dist", "coverage"],
  "include": ["./src/**/*.ts", "base32.d.ts", "telerivet.d.ts"]
}
' > tsconfig.json

echo '
module.exports = {
    "env": {
        "browser": true,
        "es2021": true
    },
    "extends": [
        "eslint:recommended",
        "plugin:@typescript-eslint/recommended"
    ],
    "overrides": [
        {
            "env": {
                "node": true
            },
            "files": [
                ".eslintrc.{js,cjs}"
            ],
            "parserOptions": {
                "sourceType": "script"
            }
        }
    ],
    "parser": "@typescript-eslint/parser",
    "parserOptions": {
        "ecmaVersion": "latest",
        "sourceType": "module"
    },
    "plugins": [
        "@typescript-eslint"
    ],
    "rules": {
    }
}
' > .eslintrc.js

# Output success message
echo "Node.js Express backend project created successfully! 🚀"
echo "Opening in vs code"
code .
echo "Starting up the server...🚀"
yarn run start

