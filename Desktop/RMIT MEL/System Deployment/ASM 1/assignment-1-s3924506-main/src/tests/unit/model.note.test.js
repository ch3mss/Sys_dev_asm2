const { MongoMemoryServer } = require('mongodb-memory-server');
const mongoose = require('mongoose');
const Note = require("../../models/note");

// Unit Tests only test the validation built into Note

describe('Note Model Tests', () => {
    let mongoServer;

    // Set up the MongoDB Memory Server before tests
    beforeAll(async () => {
        mongoServer = await MongoMemoryServer.create();
        const mongoUri = mongoServer.getUri();
        await mongoose.connect(mongoUri);
    });

    // Clean up after tests
    afterAll(async () => {
        await mongoose.disconnect();
        await mongoServer.stop();
    });

    // Reset the database between tests
    afterEach(async () => {
        await mongoose.connection.dropDatabase();
        jest.clearAllMocks();
    });

    describe("Test Both Fields Are Set", () => {
        it('Validate Model', async () => {
            const todo = new Note({
                title: "Task Note",
                description: "This is a valid description"
            });

            const result = await todo.validateSync();
            expect(result).toBe(undefined);
        });
    });
});
