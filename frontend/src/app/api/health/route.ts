import { NextResponse } from 'next/server'

export async function GET() {
  try {
    const healthStatus = {
      status: 'ok',
      version: process.env.APP_VERSION || '1.0.0',
      timestamp: new Date().toISOString(),
      service: 'autemix-frontend',
      environment: process.env.NODE_ENV || 'development'
    }

    return NextResponse.json(healthStatus, { status: 200 })
  } catch (error) {
    const errorStatus = {
      status: 'error',
      version: process.env.APP_VERSION || '1.0.0',
      timestamp: new Date().toISOString(),
      service: 'autemix-frontend',
      error: error instanceof Error ? error.message : 'Unknown error'
    }

    return NextResponse.json(errorStatus, { status: 503 })
  }
}