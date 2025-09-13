class CreateDefaultConversationForResident < ActiveRecord::Migration[8.0]
  def up
    # Backfill one conversation per resident per company
    execute <<~SQL
      INSERT INTO conversations (company_id, resident_id, created_at, updated_at)
      SELECT DISTINCT r.company_id, r.id, NOW(), NOW()
      FROM residents r
      WHERE NOT EXISTS (
        SELECT 1 FROM conversations c
        WHERE c.company_id = r.company_id AND c.resident_id = r.id
      )
    SQL
  end

  def down
    # No-op: data migration; do not delete automatically
  end
end
