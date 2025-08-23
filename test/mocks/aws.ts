import { vi } from 'vitest'

// Mock functions
export const mockS3Send = vi.fn()
export const mockDynamoSend = vi.fn()
export const mockDocSend = vi.fn()
export const mockSQSSend = vi.fn()

// Mock clients
export const mockS3Client = {
  send: mockS3Send,
}

export const mockDynamoClient = {
  send: mockDynamoSend,
}

export const mockDocClient = {
  send: mockDocSend,
}

export const mockSQSClient = {
  send: mockSQSSend,
}

// Create mock command constructors
export const mockPutObjectCommand = vi.fn((params) => ({ ...params, __type: 'PutObjectCommand' }))
export const mockGetObjectCommand = vi.fn((params) => ({ ...params, __type: 'GetObjectCommand' }))
export const mockPutCommand = vi.fn((params) => ({ ...params, __type: 'PutCommand' }))
export const mockGetCommand = vi.fn((params) => ({ ...params, __type: 'GetCommand' }))
export const mockScanCommand = vi.fn((params) => ({ ...params, __type: 'ScanCommand' }))
export const mockUpdateCommand = vi.fn((params) => ({ ...params, __type: 'UpdateCommand' }))
export const mockSendMessageCommand = vi.fn((params) => ({ ...params, __type: 'SendMessageCommand' }))
export const mockReceiveMessageCommand = vi.fn((params) => ({ ...params, __type: 'ReceiveMessageCommand' }))
export const mockDeleteMessageCommand = vi.fn((params) => ({ ...params, __type: 'DeleteMessageCommand' }))
export const mockGetQueueUrlCommand = vi.fn((params) => ({ ...params, __type: 'GetQueueUrlCommand' }))

// Mock AWS SDK modules
vi.mock('@aws-sdk/client-s3', () => ({
  S3Client: vi.fn(() => mockS3Client),
  PutObjectCommand: mockPutObjectCommand,
  GetObjectCommand: mockGetObjectCommand,
}))

vi.mock('@aws-sdk/client-dynamodb', () => ({
  DynamoDBClient: vi.fn(() => mockDynamoClient),
}))

vi.mock('@aws-sdk/lib-dynamodb', () => ({
  DynamoDBDocumentClient: {
    from: vi.fn(() => mockDocClient),
  },
  PutCommand: mockPutCommand,
  GetCommand: mockGetCommand,
  ScanCommand: mockScanCommand,
  UpdateCommand: mockUpdateCommand,
}))

vi.mock('@aws-sdk/client-sqs', () => ({
  SQSClient: vi.fn(() => mockSQSClient),
  SendMessageCommand: mockSendMessageCommand,
  ReceiveMessageCommand: mockReceiveMessageCommand,
  DeleteMessageCommand: mockDeleteMessageCommand,
  GetQueueUrlCommand: mockGetQueueUrlCommand,
}))

// Mock the aws-config module to use our mocked clients
vi.mock('@/lib/aws-config', async () => {
  const actual = await vi.importActual('@/lib/aws-config')
  return {
    ...actual,
    s3Client: mockS3Client,
    dynamoClient: mockDynamoClient,
    docClient: mockDocClient,
    sqsClient: mockSQSClient,
    AWS_RESOURCES: {
      S3_BUCKET: 'test-bucket',
      DYNAMODB_TABLE: 'TestTable',
      SQS_QUEUE: 'test-queue',
      SQS_QUEUE_URL: 'http://localhost:4566/000000000000/test-queue'
    }
  }
})

// Helper to reset all mocks
export const resetAllMocks = () => {
  mockS3Send.mockClear()
  mockDynamoSend.mockClear()
  mockDocSend.mockClear()
  mockSQSSend.mockClear()
}
