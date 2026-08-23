import sanitizeHtml from 'sanitize-html';

export function sanitizeText(value: string): string {
  return sanitizeHtml(value, {
    allowedTags: [],
    allowedAttributes: {},
  }).trim();
}

export function normalizePhone(phone: string): string {
  const cleaned = phone.replace(/[^\d+]/g, '');
  if (!cleaned.startsWith('+')) {
    throw new Error('Phone must be in E.164 format');
  }
  return cleaned;
}
