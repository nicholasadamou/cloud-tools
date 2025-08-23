import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    // Make the request to LocalStack from the server side
    const response = await fetch('http://localhost:4566/_localstack/health', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
      // Add a timeout to prevent hanging requests
      signal: AbortSignal.timeout(5000)
    })

    if (!response.ok) {
      return NextResponse.json(
        { error: 'LocalStack health check failed', status: response.status },
        { status: response.status }
      )
    }

    const healthData = await response.json()
    
    return NextResponse.json(healthData, {
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    })
  } catch (error: any) {
    console.error('LocalStack health check error:', error)
    
    return NextResponse.json(
      { 
        error: 'Failed to connect to LocalStack', 
        message: error.message,
        services: {} 
      },
      { status: 503 }
    )
  }
}
