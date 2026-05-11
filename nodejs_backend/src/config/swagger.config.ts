import swaggerJsdoc from 'swagger-jsdoc';

const options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'Food App API Documentation',
            version: '1.0.0',
            description: 'Complete API documentation for Food App backend with authentication and user management',
            contact: {
                name: 'API Support',
                email: 'support@foodapp.com'
            }
        },
        servers: [
            {
                url: `http://localhost:${process.env.PORT || 3000}`,
                description: 'Development server'
            },
            {
                url: 'http://localhost:3000',
                description: 'Local server'
            }
        ],
        components: {
            securitySchemes: {
                BearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                    description: 'JWT token for authentication'
                }
            },
            schemas: {
                User: {
                    type: 'object',
                    properties: {
                        _id: {
                            type: 'string',
                            description: 'User ID'
                        },
                        email: {
                            type: 'string',
                            description: 'User email address'
                        },
                        isEmailVerified: {
                            type: 'boolean',
                            description: 'Email verification status'
                        },
                        isPasswordResetVerified: {
                            type: 'boolean',
                            description: 'Password reset verification status'
                        },
                        createdAt: {
                            type: 'string',
                            format: 'date-time'
                        },
                        updatedAt: {
                            type: 'string',
                            format: 'date-time'
                        }
                    }
                },
                Todo: {
                    type: 'object',
                    properties: {
                        _id: {
                            type: 'string',
                            description: 'Todo ID'
                        },
                        userId: {
                            type: 'string',
                            description: 'User ID who created the todo'
                        },
                        title: {
                            type: 'string',
                            description: 'Todo title'
                        },
                        description: {
                            type: 'string',
                            description: 'Todo description'
                        },
                        isCompleted: {
                            type: 'boolean',
                            description: 'Completion status'
                        },
                        createdAt: {
                            type: 'string',
                            format: 'date-time'
                        },
                        updatedAt: {
                            type: 'string',
                            format: 'date-time'
                        }
                    }
                },
                Error: {
                    type: 'object',
                    properties: {
                        status: {
                            type: 'boolean',
                            example: false
                        },
                        message: {
                            type: 'string',
                            description: 'Error message'
                        }
                    }
                }
            }
        }
    },
    apis: [
        './src/routes/user.route.ts',
        './src/routes/todo.route.ts'
    ]
};

const swaggerSpec = swaggerJsdoc(options);

export default swaggerSpec;
